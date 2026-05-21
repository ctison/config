use ./utils/cfg.nu DIR_

# https://docs.docker.com/ai/model-runner/api-reference/

# OpenAI SDK / clients	http://localhost:12434/engines/v1
# Anthropic SDK / clients	http://localhost:12434
# Ollama-compatible clients	http://localhost:12434

export const URL = 'http://127.0.0.1:12434'

export def api [path: string] {
  http get $'($URL)($path)'
}

export def 'api models' [--raw(-R) -i] {
  http get $'($URL)/engines/v1/models'
  | if ($raw) { $in } else {
    $in.data
    | select id dmr
  }
  | if ($i) { input list } else $in
}

# See `copilot help environment`
export def copilot [model?: string] {
  let model = $model | default {
    api models
    | $in.id
    | input list
  }
  with-env {
    COPILOT_PROVIDER_BASE_URL: $'($URL)/engines/v1'
    COPILOT_PROVIDER_TYPE: 'openai'
    COPILOT_MODEL: $model
  } {
    env | grep -i 'COPILOT_'
    ^copilot
  }
}

export def setup [] {
  $DIR_ | path join pi agents models.json
  | let path
  | open $path
  | update providers.dmr.models (api models | select id)
  | tee { table -e | print }
  | save -f $path
}
