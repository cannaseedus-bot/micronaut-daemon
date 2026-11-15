# AtomicMCP tools and JROM replay

This folder is the declarative tool boundary for AtomicDOM/K'UHUL programs.

- `atomic_mcp.manifest.json` declares the MCP sidecar and its gated endpoints.
- `tool_registry.json` is the allowlist of callable tool commands.
- `jrom_replay.manifest.json` defines the append-only replay contract.
- `jrom_replay.py` records and validates JSONL replay events; it does not execute
  arbitrary commands or Python expressions.

The model proposes a tool call. The runtime resolves it against the registry,
checks the fold/lane/approval contract, and only then forwards it to the MCP
sidecar or registered Micronaut route. JROM remains the compiled AtomicDOM
container; JSONL is the readable audit/replay stream.

The .NET MCP SDK is kept unchanged under `dist/csharp-sdk`. Its host is selected
by the manifest through `C:\\Program Files\\dotnet\\dotnet.exe` and the existing
`dist\\micronauts\\micronaut-mcp-cs\\launch.bat` entrypoint.
