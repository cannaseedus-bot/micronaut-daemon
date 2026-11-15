# {{app_name}}

{{description}}

Built with Vite + React + TypeScript + Tailwind. Connects to KHANARY runtime at port {{rpc_port}}.

## Quick start

```
npm install
npm run dev
```

## Brand

| Token         | Value          |
|---------------|----------------|
| `--brand`     | `{{brand_color}}` |
| `--brand-dark`| `{{brand_dark}}`  |

## Features

{{features}}

## KHANARY connection

`src/khanary.ts` exports `rpc(method, params)`, `keyQuery(query)`, and `foldScore(keys)`.
Vite proxies `/rpc` and `/mcp` to `http://127.0.0.1:{{rpc_port}}`.
