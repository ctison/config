export const DIR_CACHE_HUGFACE = '~/.cache/huggingface/hub/' | path expand
export const DEFAULT_QWEN = 'mlx-community/Qwen3.6-35B-A3B-4bit'

# cSpell:words vllm mlx

# List models in the Hugging Face cache
export def ls []: [
  nothing -> table<
    id: string
    type: string
    size: filesize
    nb_files: int
    last_accessed: datetime
    last_modified: datetime
    path: string
  >
] {
  mlx_lm.manage --scan
  | lines
  | skip 3
  | parse -r '^\s*(?<id>[^\s]+)\s+(?<type>[^\s]+)\s+(?<size>[^\s]+)\s+(?<nb_files>[^\s]+)\s+(?<last_accessed>.+?)\s{2,}(?<last_modified>.+?)\s{2,}(?<path>.+)$'
  | update size { into filesize }
  | update nb_files { into int }
  | update last_accessed { date from-human }
  | update last_modified { date from-human }
  | sort-by --reverse last_modified
}

# Start the LLM server
export def 'qwen start' [
  # Interactively choose a model from the cache
  --interactive(-i)
  # Server host
  --host(-h): string = '127.0.0.1'
  # Server port
  --port(-p): int = 7777
] {
  let model = if $interactive {
    models | $in.id | input list 'Choose a model:' --fuzzy
   } else $DEFAULT_QWEN
  log info $'Model: ($model)'
  (vllm-mlx serve
    --host $host
    --port $port
    --enable-auto-tool-choice
    --tool-call-parser qwen
    --reasoning-parser qwen3
    --served-model-name qwen3
    $model
  )
}

# Start gemma with Multi-Token Prediction
export def 'gemma start' [] {
  (mlx_vlm.server
      --host 127.0.0.1
      --port 7777
      --log-level DEBUG
      --model mlx-community/gemma-4-E4B-it-bf16
      --draft-model mlx-community/gemma-4-E4B-it-assistant-bf16
      --draft-kind mtp
      --draft-block-size 4
  )
}
