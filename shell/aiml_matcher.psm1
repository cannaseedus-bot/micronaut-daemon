#Requires -Version 5.1
<#
  aiml_matcher.psm1 — PowerShell AIML pattern matcher
  Implements the kuhul/AIML specificity formula and pattern compilation.
  Used as a local fallback when the AIML daemon (port 3217) is offline.
  Integrates with micronaut_bindings.psm1 via Invoke-MicronautMatch.
#>

using namespace System.Text.RegularExpressions
using namespace System.Collections.Generic

# ── Data classes ──────────────────────────────────────────────────────────────

class AimlPattern {
    [string]   $MicronautId
    [string]   $Pattern
    [string]   $Topic
    [string]   $That
    [regex]    $Compiled
    [double]   $Specificity
    [int]      $WildcardCount
    [int]      $UnderscoreCount
    [int]      $LiteralChars

    AimlPattern([string]$id, [string]$pattern, [string]$topic, [string]$that) {
        $this.MicronautId     = $id
        $this.Pattern         = $pattern
        $this.Topic           = $topic
        $this.That            = $that
    }
}

class AimlMatch {
    [string]   $MicronautId
    [string]   $MatchedPattern
    [string[]] $Stars
    [double]   $Confidence
    [bool]     $Hit

    AimlMatch([string]$id, [string]$pattern, [string[]]$stars, [double]$confidence) {
        $this.MicronautId   = $id
        $this.MatchedPattern = $pattern
        $this.Stars         = $stars
        $this.Confidence    = $confidence
        $this.Hit           = $true
    }

    static [AimlMatch] Miss() {
        $m = [AimlMatch]::new('', '', @(), 0.0)
        $m.Hit = $false
        return $m
    }
}

class AimlMatcher {
    hidden [List[AimlPattern]] $Patterns
    hidden [Dictionary[string, AimlPattern]] $ExactIndex

    AimlMatcher() {
        $this.Patterns   = [List[AimlPattern]]::new()
        $this.ExactIndex = [Dictionary[string, AimlPattern]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    # Normalize: uppercase → strip non-word/space → collapse whitespace → trim
    [string] Normalize([string]$text) {
        $r = $text.ToUpper()
        $r = [regex]::Replace($r, '[^\w\s]', ' ')
        $r = [regex]::Replace($r, '\s+', ' ')
        return $r.Trim()
    }

    # Specificity formula (from aiml_pattern_bank.ebnf):
    # exact=1.0; wildcards: clamp(0.5+(litChars/(litChars+wcCount))*0.5 - wcCount*0.15 + undCount*0.10, 0.0, 1.0)
    hidden [double] CalcSpecificity([int]$litChars, [int]$wcCount, [int]$undCount) {
        if ($wcCount -eq 0 -and $undCount -eq 0) { return 1.0 }
        $raw = 0.5 + ($litChars / ($litChars + $wcCount + $undCount)) * 0.5 `
               - $wcCount * 0.15 `
               + $undCount * 0.10
        return [Math]::Max(0.0, [Math]::Min(1.0, $raw))
    }

    # Compile a kuhul/AIML pattern to a regex:
    #   * → (.+)   greedy star
    #   _ → (.+?)  lazy underscore (higher priority than *)
    #   spaces → \s+
    #   anchored ^ ... $
    hidden [void] CompileInto([AimlPattern]$ap) {
        $norm    = $this.Normalize($ap.Pattern)
        $litBuf  = ''
        $regBuf  = ''
        $wcCount = 0
        $undCount = 0

        for ($i = 0; $i -lt $norm.Length; $i++) {
            $ch = $norm[$i]
            if ($ch -eq '*') {
                if ($litBuf) { $regBuf += [regex]::Escape($litBuf); $litBuf = '' }
                $regBuf += '(.+)'
                $wcCount++
            } elseif ($ch -eq '_') {
                if ($litBuf) { $regBuf += [regex]::Escape($litBuf); $litBuf = '' }
                $regBuf += '(.+?)'
                $undCount++
            } elseif ($ch -eq ' ') {
                if ($litBuf) { $regBuf += [regex]::Escape($litBuf); $litBuf = '' }
                $regBuf += '\s+'
            } else {
                $litBuf += $ch
            }
        }
        if ($litBuf) { $regBuf += [regex]::Escape($litBuf) }

        $ap.Compiled        = [regex]::new("^$regBuf$", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $ap.LiteralChars    = ($norm -replace '[*_ ]','').Length
        $ap.WildcardCount   = $wcCount
        $ap.UnderscoreCount = $undCount
        $ap.Specificity     = $this.CalcSpecificity($ap.LiteralChars, $wcCount, $undCount)
    }

    [void] RegisterPattern([string]$id, [string]$pattern, [string]$topic, [string]$that) {
        $ap = [AimlPattern]::new($id, $pattern, $topic, $that)
        $this.CompileInto($ap)

        # exact patterns go into the hash index for O(1) lookup
        if ($ap.WildcardCount -eq 0 -and $ap.UnderscoreCount -eq 0) {
            $key = "$($this.Normalize($pattern))|$topic|$that"
            $this.ExactIndex[$key] = $ap
        }

        $this.Patterns.Add($ap)
    }

    [AimlMatch] Match([string]$text, [string]$topic, [string]$that) {
        $norm = $this.Normalize($text)

        # exact-index fast path
        $key = "$norm|$topic|$that"
        if ($this.ExactIndex.ContainsKey($key)) {
            $ap = $this.ExactIndex[$key]
            return [AimlMatch]::new($ap.MicronautId, $ap.Pattern, @(), 1.0)
        }

        # wildcard scan — highest specificity wins
        $best      = $null
        $bestSpec  = -1.0
        $bestStars = @()

        foreach ($ap in $this.Patterns) {
            # topic/that filter
            if ($ap.Topic -and $ap.Topic -ne '*' -and $ap.Topic -ne $topic)  { continue }
            if ($ap.That  -and $ap.That  -ne '*' -and $ap.That  -ne $that)   { continue }

            $m = $ap.Compiled.Match($norm)
            if (-not $m.Success) { continue }

            if ($ap.Specificity -gt $bestSpec) {
                $bestSpec  = $ap.Specificity
                $best      = $ap
                $bestStars = @(1..($m.Groups.Count - 1) | ForEach-Object { $m.Groups[$_].Value })
            }
        }

        if ($best) {
            return [AimlMatch]::new($best.MicronautId, $best.Pattern, $bestStars, $bestSpec)
        }
        return [AimlMatch]::Miss()
    }

    [void] Clear() {
        $this.Patterns.Clear()
        $this.ExactIndex.Clear()
    }

    [int] Count() { return $this.Patterns.Count }
}


# ── Module-level default instance ─────────────────────────────────────────────

$script:DefaultMatcher = [AimlMatcher]::new()


# ── Exported functions ────────────────────────────────────────────────────────

function New-AimlMatcher {
    return [AimlMatcher]::new()
}

function Register-AimlPattern {
    <#.SYNOPSIS Register one pattern into the default matcher (or a provided one).
    .PARAMETER MicronautId  Micronaut that owns this pattern.
    .PARAMETER Pattern      AIML-style pattern string (* for greedy, _ for lazy).
    .PARAMETER Topic        Topic scope (empty = any).
    .PARAMETER That         Prior-response guard (empty = any).
    .PARAMETER Matcher      Use a specific matcher instance instead of the default.
    #>
    param(
        [Parameter(Mandatory)][string]$MicronautId,
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Topic   = '',
        [string]$That    = '',
        [AimlMatcher]$Matcher = $null
    )
    $m = if ($Matcher) { $Matcher } else { $script:DefaultMatcher }
    $m.RegisterPattern($MicronautId, $Pattern, $Topic, $That)
}

function Invoke-AimlMatch {
    <#.SYNOPSIS Match a normalized input against the registered pattern bank.
    Returns an AimlMatch object with .Hit, .MicronautId, .Stars, .Confidence.
    #>
    param(
        [Parameter(Mandatory)][string]$Text,
        [string]$Topic   = '',
        [string]$That    = '',
        [AimlMatcher]$Matcher = $null
    )
    $m = if ($Matcher) { $Matcher } else { $script:DefaultMatcher }
    return $m.Match($Text, $Topic, $That)
}

function Clear-AimlBank {
    param([AimlMatcher]$Matcher = $null)
    $m = if ($Matcher) { $Matcher } else { $script:DefaultMatcher }
    $m.Clear()
}

function Get-AimlBankCount {
    param([AimlMatcher]$Matcher = $null)
    $m = if ($Matcher) { $Matcher } else { $script:DefaultMatcher }
    return $m.Count()
}

function Import-AimlBank {
    <#.SYNOPSIS Load patterns from a JSONL aiml-bank file or an AIML XML file into the default (or provided) matcher.
    JSONL format: {"type":"aiml_micronaut","id":"NAME-µ","data":{"pattern":"...","topic":"..."}}
    AIML XML format: standard <category>/<pattern>/<topic>/<that> elements.
    #>
    param(
        [Parameter(Mandatory)][string]$Path,
        [AimlMatcher]$Matcher = $null
    )
    $m   = if ($Matcher) { $Matcher } else { $script:DefaultMatcher }
    $abs = if ([IO.Path]::IsPathRooted($Path)) { $Path } else { Join-Path $PSScriptRoot $Path }
    if (-not (Test-Path $abs)) { Write-Warning "Import-AimlBank: not found: $abs"; return 0 }

    $count = 0
    $ext   = [IO.Path]::GetExtension($abs).ToLower()

    if ($ext -eq '.jsonl' -or $ext -eq '.json') {
        foreach ($line in [IO.File]::ReadAllLines($abs)) {
            $line = $line.Trim()
            if (-not $line -or $line[0] -ne '{') { continue }
            try {
                $obj = $line | ConvertFrom-Json
                if ($obj.type -in @('aiml_micronaut','srai_micronaut') -and $obj.id -and $obj.data.pattern) {
                    $m.RegisterPattern($obj.id, $obj.data.pattern,
                        ([string]$obj.data.topic),
                        ([string]$obj.data.that))
                    $count++
                }
            } catch {}
        }
    } elseif ($ext -eq '.xml' -or $ext -eq '.aiml') {
        [xml]$xml = Get-Content $abs -Raw
        $topicName = ''
        foreach ($node in $xml.SelectNodes('//*')) {
            if ($node.LocalName -eq 'topic') { $topicName = $node.name }
            if ($node.LocalName -eq 'category') {
                $pat   = $node.SelectSingleNode('pattern')
                $that  = $node.SelectSingleNode('that')
                $tmpl  = $node.SelectSingleNode('template')
                if ($pat -and $tmpl) {
                    $id = "aiml:$($pat.InnerText -replace '\s+','_' -replace '[^A-Za-z0-9_]','')"
                    $m.RegisterPattern($id, $pat.InnerText.Trim(),
                        $topicName,
                        (if ($that) { $that.InnerText.Trim() } else { '' }))
                    $count++
                }
            }
        }
    } else {
        Write-Warning "Import-AimlBank: unsupported format '$ext' (use .jsonl or .xml/.aiml)"
    }

    return $count
}

Export-ModuleMember -Function `
    New-AimlMatcher, `
    Register-AimlPattern, Invoke-AimlMatch, `
    Clear-AimlBank, Get-AimlBankCount, Import-AimlBank
