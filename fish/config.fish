set currentHistory ''

function completeOrHistory -a direction
    # Set up history and completion commands based on direction
    if test "$direction" = 'backwards'
        set historyCmd history-search-backward
        set completeCmd complete-and-search
    else
        set historyCmd history-search-forward
        set completeCmd complete
    end

    # Check if the command line is empty or not
    if test (commandline -b) = "$currentHistory" || test (commandline -b) = ""
        commandline -f $historyCmd
        set currentHistory (commandline -b)
    else
        commandline -f $completeCmd
        set currentHistory ' '
    end
end

function completeOrHistoryBackwards
    completeOrHistory backwards
end

function bindModes
    set keys $argv[-2]
    set command $argv[-1]

    for mode in $argv[1..-3]
        bind -M $mode $keys $command
    end
end

if status is-interactive
    set fish_greeting -Ux fish_greeting "🐟"

    fish_vi_key_bindings
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

    bindModes insert default \co accept-autosuggestion
    bindModes insert default \cn completeOrHistory
    bindModes insert default \cp completeOrHistoryBackwards

    set -gx PATH $PATH $HOME/.zig
end
