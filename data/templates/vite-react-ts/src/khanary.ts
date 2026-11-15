const RPC = 'http://127.0.0.1:{{rpc_port}}/rpc'

let _id = 1

export async function rpc<T = unknown>(method: string, params: unknown = {}): Promise<T> {
  const res = await fetch(RPC, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ jsonrpc: '2.0', id: _id++, method, params }),
  })
  const data = await res.json()
  if (data.error) throw new Error(data.error.message ?? String(data.error))
  return data.result as T
}

export const keyQuery  = (query: string)  => rpc<string[]>('key_query',  { query })
export const foldScore = (keys: string[]) => rpc<number[]>('fold_score', { keys })
