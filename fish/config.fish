set fish_color_autosuggestion 777777
set fish_color_command 00FF00
set fish_color_comment 30BE30
set fish_color_cwd green
set fish_color_cwd_root red
set fish_color_end FF7B7B
set fish_color_error A40000
set fish_color_escape cyan
set fish_color_history_current cyan
set fish_color_host -o cyan
set fish_color_match cyan
set fish_color_normal normal
set fish_color_operator cyan
set fish_color_param 30BE30
set fish_color_quote 44FF44
set fish_color_redirection 7BFF7B
set fish_color_search_match --background=purple
set fish_color_selection --background=purple
set fish_color_status red
set fish_color_user -o green
set fish_color_valid_path --underline

umask 0077

fish_add_path -Pa \
    ~/.cargo/bin ~/go/bin \
    ~/.local/bin /opt/homebrew/bin \
    ~/.docker/bin ~/.krew/bin

if type -q mise 2>/dev/null
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

if status is-interactive
    function _cmd_exists -a COMMAND
        type -q $COMMAND 2>/dev/null
    end
    function _add_alias -a NAME COMMAND
        if _cmd_exists $COMMAND
            alias $NAME="$argv[2..-1]"
        end
    end

    _add_alias g git
    _add_alias lg lazygit
    _add_alias k kubectl
    _add_alias kz kubectl kustomize --enable-helm
    _add_alias k9s k9s --logoless --headless -c pu
    _add_alias kt kustomize cfg tree -
    _add_alias kg kustomize cfg grep --annotate=false
    _add_alias p pulumi
    _add_alias tar tar --no-same-o --no-same-p
    _add_alias h xh https://httpbin.org/anything

    _add_alias gpg gpg --keyid-format long
    if _cmd_exists gpg
        set -gx GPG_TTY (tty)
    end


    _add_alias dc docker compose
    _add_alias dx docker buildx
    if _cmd_exists docker
        set -gx DOCKER_BUILDKIT 1
    end

    if _cmd_exists code-insiders
        set -gx EDITOR 'code-insiders -w'
        alias code='code-insiders'
        alias vscode='command code'
    else if _cmd_exists code
        set -gx EDITOR 'code -w'
    end

    if _cmd_exists eza
        alias l='eza -lag --group-directories-first --git'
        alias t='l -T'
        alias ll='l -a'
    end

    if _cmd_exists starship
        starship init fish | source
    end
end

### Setup config
for d in ~/x/config /config
    if test -d "$d/bin"
        fish_add_path -Pa "$d/bin"
        alias man="man -P $d/bin/pager"
        set -gx PAGER "$d/bin/pager"
        break
    end
end
