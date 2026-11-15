"""Bounded CODER-µ grammar operations. No source execution or file writes."""

import argparse
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GRAMMARS = {
    "cpp": ROOT / "data/grammar/cpp.code-grammar.json",
    "typescript": ROOT / "data/grammar/typescript.code-grammar.json",
}
IDENTIFIER = re.compile(r"[A-Za-z_][A-Za-z0-9_]*\Z")


def compile_grammar(language):
    path = GRAMMARS[language]
    grammar = json.loads(path.read_text(encoding="utf-8"))
    if grammar.get("language") != language:
        raise ValueError("grammar language does not match the selected language")
    tokens = grammar.get("tokens")
    if not isinstance(tokens, list) or not tokens:
        raise ValueError("grammar has no tokens")
    compiled = []
    for token in tokens:
        name, pattern = token.get("type"), token.get("pattern")
        if not isinstance(name, str) or not isinstance(pattern, str):
            raise ValueError("token type and pattern must be strings")
        regex = re.compile(pattern, re.MULTILINE)
        captures = token.get("captures", [])
        if len(captures) > regex.groups:
            raise ValueError(f"{name}: more capture names than regex groups")
        compiled.append((name, regex, captures))
    return grammar, compiled


def parse_source(language, source):
    grammar, compiled = compile_grammar(language)
    nodes = []
    for name, regex, captures in compiled:
        for match in regex.finditer(source):
            nodes.append({
                "type": name,
                "start": match.start(),
                "end": match.end(),
                "captures": {key: match.group(index + 1) for index, key in enumerate(captures)},
            })
    nodes.sort(key=lambda node: (node["start"], node["end"], node["type"]))
    return {"schema": "micronaut.coder-grammar-parse.v1", "language": language,
            "grammar_version": grammar.get("version"), "nodes": nodes,
            "authority": "data_only"}


def generate_source(language, name):
    if not IDENTIFIER.fullmatch(name):
        raise ValueError("name must be a valid identifier")
    if language == "cpp":
        source = f"int {name}(int value) {{\n    return value;\n}}\n"
    else:
        source = f"export function {name}(value: number): number {{\n  return value;\n}}\n"
    parsed = parse_source(language, source)
    if not any(node["type"] in ("function_def", "function_decl") for node in parsed["nodes"]):
        raise ValueError("generated source was not recognized by its grammar")
    return {"schema": "micronaut.coder-grammar-generate.v1", "language": language,
            "source": source, "parsed": parsed, "authority": "proposal_only"}


def validate_ast(language, source, proposed):
    if not isinstance(proposed, dict) or not isinstance(proposed.get("nodes"), list):
        raise ValueError("AST proposal must contain a nodes array")
    canonical = parse_source(language, source)
    nodes = proposed["nodes"]
    if len(nodes) > 512:
        raise ValueError("AST proposal exceeds 512 nodes")
    valid = proposed.get("language") == language and nodes == canonical["nodes"]
    return {"schema": "micronaut.coder-ast-validation.v1", "language": language,
            "valid": valid, "canonical": canonical,
            "reason": "matched_grammar_parse" if valid else "ast_does_not_match_grammar_parse",
            "authority": "validation_only"}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("compile", "parse", "generate", "validate_ast"))
    parser.add_argument("--language", choices=tuple(GRAMMARS), required=True)
    parser.add_argument("--source", default="")
    parser.add_argument("--name", default="")
    parser.add_argument("--ast-json", default="")
    args = parser.parse_args()
    try:
        if args.operation == "compile":
            grammar, compiled = compile_grammar(args.language)
            result = {"schema": "micronaut.coder-grammar-compile.v1",
                      "language": args.language, "grammar_version": grammar.get("version"),
                      "token_types": [name for name, _, _ in compiled],
                      "token_count": len(compiled), "authority": "validation_only"}
        elif args.operation in ("parse", "validate_ast"):
            if len(args.source) > 16384:
                raise ValueError("source exceeds 16384 characters")
            result = (parse_source(args.language, args.source) if args.operation == "parse"
                      else validate_ast(args.language, args.source,
                                        json.loads(sys.stdin.read() if args.ast_json == "-" else args.ast_json)))
        else:
            result = generate_source(args.language, args.name)
        print(json.dumps(result, ensure_ascii=False))
    except (OSError, ValueError, re.error, json.JSONDecodeError) as error:
        parser.exit(2, f"coder grammar: {error}\n")


if __name__ == "__main__":
    main()
