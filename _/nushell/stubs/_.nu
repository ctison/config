use ./api

use ./adb.nu
use ./bat.nu
use ./brew.nu
use ./bun.nu
use ./cargo.nu
use ./claude.nu
use ./code-server.nu
use ./code.nu
use ./codex.nu
use ./copilot.nu
use ./defaults.nu
use ./docker.nu *
use ./firefox.nu
use ./fnox.nu
use ./git.nu
use ./mise.nu
use ./mount.nu
use ./mutagen.nu
use ./pbcopy.nu
use ./rg.nu
use ./sk.nu
use ./uv.nu
use ./xh.nu
use ./zellij.nu

# cSpell:disable

alias mcpc     = bun x --bun -p @apify/mcpc mcpc
alias pi       = bun x --bun -p @earendil-works/pi-coding-agent pi
alias qwen     = bun x --bun -p @qwen-code/qwen-code qwen
alias vllm-mlx = uv tool run --from vllm-mlx vllm-mlx
