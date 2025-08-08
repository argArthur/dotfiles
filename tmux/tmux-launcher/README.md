# TMUX LAUNCHER

tmux-launcher is a script that extends [tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer) to launch a custom session through a session-name.tmux.conf file where you can set options for tmux and launch windows and panes and anythin that can be done in your .tmux.conf

![](docs/showcase.gif)

Use fzf to select active tmux sessions to switch to, launch sessions with launch files, or create a session base on a directory in the projects folder

## Instaling

### dependencies 
fzf and tmux

---

clone this repository or copy [tmuxlauncher](tmuxlauncher) into your computer, and mark it as executable with
```
chmod +x tmuxlauncher
```

then create a sessions directory in the same folder as tmuxlauncher where it will look for session files (this can be edited in the script) and add whatever sessions you want to it

### add to path
next I recommend adding the executable to a path where the system looks for executables.

I recommend adding it to /usr/local/bin with a symlink
```
sudo ln -s "$(pwd)/tmuxlauncher" /usr/local/bin/tmuxlauncher
```
from here you are good to go to just type `tmuxlauncher` in your terminal, but I do some additional configuring for ease of use.

### bindings
You can abbreviate it in your shell like so:

**fish**
```
abbr -a tml tmuxlauncher
```

**zsh**
```
alias tml="tmuxlauncher"
```

**bash**
```
alias tml="tmuxlauncher"
```

You can also bind it in tmux like so:
```
bind l neww tmuxlauncher
bind -n M-l neww tmuxlauncher
```

Of course you can choose another bind or maybe bind it for your whole terminal emulator, it is personal preference

## Session files

```tmux [filename=configs.tmux.conf]
# Set the directory for new windows (when starting the session)
set-option -g default-command "cd ~/.config; exec $SHELL"

rename-window 'vimrc'
send-keys -t 'vimrc' 'cd ~/.config/nvim/lua/configLegal; clear; nvim' C-m

neww -n 'tmux'
send-keys -t 'tmux' 'cd ~/.config/tmux; clear; nvim tmux.conf' C-m

neww -n 'fish' -c ~/.config/fish
send-keys -t 'fish' 'cd ~/.config/fish; clear; nvim config.fish' C-m

neww -n 'ghostty'
send-keys -t 0 'cd ~/.config/ghostty; clear; nvim config' C-m

neww -n '.conf'

select-window -t 'vimrc'
```

The script will look for theese files in  ./sessions , and it will source it in the session it creates with `tmux source-file`

'session' files are simply tmux config files like .tmux.conf
