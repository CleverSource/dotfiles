set fish_greeting ""
fzf_configure_bindings --directory=\cf

if type -q starship
    starship init fish | source
end

alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff='fzf --preview "bat --style=numbers --color=always {}"'