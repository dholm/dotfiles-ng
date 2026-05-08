if ((PROFILE)); then
    zmodload zsh/zprof
fi

# shellcheck source=../../.shellrc
. "${HOME}/.shellrc"


zshrc::zinit() {
    local zinit_home="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if [[ ! -d "${zinit_home}" ]]; then
         mkdir -p "$(dirname "${zinit_home}")"
         if [[ ! -d "${zinit_home}/.git" ]]; then
             git clone https://github.com/zdharma-continuum/zinit.git "${zinit_home}"
         fi
    fi

    source "${zinit_home}/zinit.zsh"
}
zshrc::zinit

zshrc::history() {
    # Set path to history file.
    export HISTFILE=~/.zsh_history
    # Increase length of history.
    export HISTSIZE=100000
    export SAVEHIST=${HISTSIZE}

    # Allow multiple terminal sessions to all append to one zsh
    # command history.
    setopt append_history
    # Save time stamp of command and duration.
    setopt extended_history
    # Add commands as they are typed, don't wait until shell exit.
    setopt inc_append_history
    # When trimming history, lose oldest duplicates first.
    setopt hist_expire_dups_first
    # Do not write events to history that are duplicates of previous
    # events.
    setopt hist_ignore_dups
    # Delete old entry if new one is a duplicate.
    setopt hist_ignore_all_dups
    # Don't write duplicate entries in the history file.
    setopt hist_save_no_dups
    # Remove command line from history list when first character on
    # the line is a space.
    setopt hist_ignore_space
    # When searching history don't display results already cycled
    # through twice.
    setopt hist_find_no_dups
    # Remove extra blanks from each command line being added to
    # history.
    setopt hist_reduce_blanks
    # Don't execute, just expand history.
    setopt hist_verify
    # Imports new commands and appends typed commands to history.
    setopt share_history

    alias zhistory="builtin history -di 1"

    # Allow patterns in searches by default.
    bindkey '^R' history-incremental-pattern-search-backward
    bindkey '^S' history-incremental-pattern-search-forward
}
shell::eval zshrc::history


zshrc::bookmarks() {
    setopt cd_able_vars
    if [[ -r "${HOME}/.zsh_bookmarks" ]]; then
        # shellcheck source=../../.zsh_bookmarks
        . "${HOME}/.zsh_bookmarks"
    fi
}
shell::is_dumb || shell::eval zshrc::bookmarks


shell::is_dumb || zinit light zsh-users/zsh-completions


zshrc::zinit_bundles() {
    zinit snippet OMZP::command-not-found
    zinit snippet OMZP::battery
    zinit snippet OMZP::extract
    zinit snippet OMZP::dircycle
    zinit snippet OMZP::gnu-utils

    local binaries=(brew cp cpanm docker-compose docker emacs fasd gem
                    helm node keychain kubectl man minikube mosh nmap
                    node npm perl pip python redis-cli rsync ruby sbt
                    scala ssh-agent sudo svn systemd)
    for binary in "${binaries[@]}"; do
        path::has_binary "${binary}" && zinit snippet OMZP::${binary}
    done

    if path::has_binary go; then
        zinit snippet OMZP::go
        zinit snippet OMZP::golang
    fi

    if path::has_binary tmux; then
        zinit snippet OMZP::tmux
        zinit snippet OMZP::tmuxinator
    fi

    if path::has_binary git; then
        zinit snippet OMZP::git
        zinit snippet OMZP::github
        zinit snippet OMZP::gitignore
    fi

    if path::has_binary hg; then
        zinit snippet OMZP::mercurial
    fi

    os::is_darwin && zinit snippet OMZP::osx
}
shell::is_dumb || shell::eval zshrc::zinit_bundles


zshrc::prompt() {
    zinit light mafredri/zsh-async
    zinit ice pick"pure.zsh" as"theme"
    zinit light sindresorhus/pure

    # Single line prompt.
    export prompt_newline='%666v'
    PROMPT=" $PROMPT"
}
shell::is_dumb || shell::eval zshrc::prompt


shell::is_dumb || zinit light zsh-users/zsh-syntax-highlighting


zshrc::dumb_terminal() {
    # Fallback for dumb terminals (i.e. when running under Emacs Tramp).
    print::debug "Dumb terminal detected, falling back to safe mode."
    unsetopt zle
    unsetopt prompt_cr
    unsetopt prompt_subst
    shell::has_function precmd && unfunction precmd
    shell::has_function preexec && unfunction preexec
}
shell::is_dumb && shell::eval zshrc::dumb_terminal


zshrc::darwin_setup() {
    if [ -d "/usr/share/zsh/help" ]; then
        HELPDIR="/usr/share/zsh/help"
    elif [ -d "/usr/local/share/zsh/help" ]; then
        HELPDIR="/usr/local/share/zsh/help"
    elif path::has_binary brew; then
        unalias run-help
        autoload run-help
        # shellcheck disable=SC2034
        HELPDIR=$(brew --prefix)/share/zsh/help
    fi
}
os::is_darwin && shell::eval zshrc::darwin_setup


# shellcheck source=../../.zshrc.local
# shellcheck disable=SC2091
$(shell::source "${HOME}/.zshrc.local")
# shellcheck source=../../.zsh_aliases.local
# shellcheck disable=SC2091
$(shell::source "${HOME}/.zsh_aliases.local")
