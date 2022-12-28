if status is-interactive
end

set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/Applications $fish_user_paths
set -g __fish_git_prompt_show false 
set -g __fish_git_prompt_use_informative_chars false
### EXPORT ###
set fish_greeting
set TERM "xterm-256color"
set EDITOR "nvoid"
set VISUAL "nvoid" 
set -x MANPAGER "nvim -c 'set ft=man' -"
function fish_git_prompt
end
function fish_mode_prompt
  switch $fish_bind_mode
    case default
      echo -en "\e[2 q"
      set_color -o brwhite
      echo "["
      set_color -o brred
      echo "N"
      set_color -o brwhite
      echo "]"
    case insert
      echo -en "\e[6 q"
      set_color -o brwhite
      echo "["
      set_color -o brgreen
      echo "I"
      set_color -o brwhite
      echo "]"
    case replace_one
      echo -en "\e[4 q"
      set_color -o brwhite
      echo "["
      set_color -o bryellow
      echo "R"
      set_color -o brwhite
      echo "]"
    case visual
      echo -en "\e[2 q"
      set_color -o brwhite
      echo "["
      set_color -o brmagenta
      echo "V"
      set_color -o brwhite
      echo "]"
    case '*'
      echo -en "\e[2 q"
      set_color -o brwhite
      echo "["
      set_color -o brred
      echo "?"
      set_color -o brwhite
      echo "]"
  end
  set_color normal
end

function fish_hybrid_key_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase
end
set -g fish_key_bindings fish_hybrid_key_bindings

alias v='nvoid'
alias cp="cp -ri"
alias rm="rm -ri"
alias ls='exa --group-directories-first --icons -la'
alias ll='exa'
alias up='sudo pacman -Syyu'
alias orphans='sudo pacman -Qtdq | sudo pacman -Rns -'


function fish_prompt --description 'Write out the prompt'

    set -l git_info
    if set -l git_branch (command git symbolic-ref HEAD 2>/dev/null | string replace refs/heads/ '')
        set git_branch (set_color -o blue)"$git_branch"
        set -l git_status
        if not command git diff-index --quiet HEAD --
            if set -l count (command git rev-list --count --left-right $upstream...HEAD 2>/dev/null)
                echo $count | read -l ahead behind
                if test "$ahead" -gt 0
                    set git_status "$git_status"(set_color red)⬆
                end
                if test "$behind" -gt 0
                    set git_status "$git_status"(set_color red)⬇
                end
            end
            for i in (git status --porcelain | string sub -l 2 | sort | uniq)
                switch $i
                    case "."
                        set git_status "$git_status"(set_color green)✚
                    case " D"
                        set git_status "$git_status"(set_color red)✖
                    case "*M*"
                        set git_status "$git_status"(set_color green)✱
                    case "*R*"
                        set git_status "$git_status"(set_color purple)➜
                    case "*U*"
                        set git_status "$git_status"(set_color brown)═
                    case "??"
                        set git_status "$git_status"(set_color red)≠
                end
            end
        else
            set git_status (set_color green):
        end
        set git_info " (git$git_status$git_branch"(set_color white)")"
    end

    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l laststatus $status

    set -l color_cwd
    set -l suffix
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        else
            set color_cwd $fish_color_cwd
        end
        set suffix '#'
    else
        set color_cwd $fish_color_cwd
        set suffix ''
    end

    set_color normal
    printf '%s ' (fish_vcs_prompt)
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color --bold $fish_color_status)
     # set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)
    set_color normal
    echo -n (set_color blue) [(set_color normal)(whoami)(set_color red)@(set_color normal)(hostname)(set_color blue)]"$git_info" (set_color $color_cwd)(prompt_pwd) (echo)
    if test $laststatus -eq 0
        echo -n (set_color green)"$suffix"(set_color white) (set_color normal)
    else
        echo -n  (set_color red)"$suffix"(set_color white) (set_color normal)
    end
end
