if status is-interactive
    # fish_vi_key_bindings
    set -U fish_cursor_unknown block
    set fish_cursor_default block
    set fish_cursor_unknown block
    set fish_cursor_insert  block
    set fish_cursor_replace block
    set fish_cursor_visual  block

    abbr -a tml tmuxlauncher

    abbr -a fzx 'fzf --print0 | xargs -x0 --'
    abbr -a cat 'batcat'
    set -Ux FZF_DEFAULT_OPTS "--bind 'tab:up' --bind 'shift-tab:down'"

    abbr -a gfa 'fzf --print0 | xargs -x0 -- git add'

    abbr -a gl 'git log --oneline --graph --decorate'
    abbr -a gc 'git commit'
    abbr -a gco 'git checkout'
    abbr -a gb 'git branch'
    abbr -a gw 'git worktree'
    abbr -a gp 'git push'
    abbr -a gpl 'git pull'
    abbr -a gs 'git status'

    abbr -a clear 'clear; fish_greeting'

    bind \co forward-char
    bind \cn complete
    bind \cp complete-and-search
end
