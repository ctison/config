# cSpell:disable

def --wrapped pi [...rest] {
  bun x --bun -p @earendil-works/pi-coding-agent pi ...$rest
}

def --wrapped vllm-mlx [...rest] {
  uv tool run --from vllm-mlx vllm-mlx ...$rest
}

def --wrapped mcpc [...rest] {
  bun x --bun -p @apify/mcpc mcpc ...$rest
}

def --wrapped codex [...rest] {
  bun x --bun -p @openai/codex codex ...$rest
}
