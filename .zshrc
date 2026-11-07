if ((PROFILE)); then
    zmodload zsh/zprof
fi

# shellcheck source=../../.shellrc
. "${HOME}/.shellrc"

zshrc::zinit() {
    local zinit_home="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    # Pinned, like the plugins below; bump deliberately after reviewing
    # upstream changes.
    local zinit_ver="d2d4237715081ea138eb1a9d4a7d1634eec7a36e"
    if [[ ! -d "${zinit_home}" ]]; then
        mkdir -p "$(dirname "${zinit_home}")"
        git clone https://github.com/zdharma-continuum/zinit.git "${zinit_home}" &&
            git -C "${zinit_home}" checkout --quiet "${zinit_ver}"
    fi

    source "${zinit_home}/zinit.zsh"
}
# Nothing uses zinit in dumb terminals (e.g. Emacs Tramp), so do not load or
# install it there.
shell::is_dumb || zshrc::zinit

zshrc::history() {
    # Set path to history file.
    HISTFILE=~/.zsh_history
    # Ensure HISTFILE does not end up in the environment and
    # accidentally used by another shell, such as Bash.
    typeset +x HISTFILE
    # Increase length of history. Like HISTFILE, keep these out of the
    # environment so that Bash does not pick them up.
    HISTSIZE=100000
    SAVEHIST=${HISTSIZE}
    typeset +x HISTSIZE SAVEHIST

    # Allow multiple terminal sessions to all append to one zsh
    # command history.
    setopt append_history
    # Save time stamp of command and duration.
    setopt extended_history
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
    # Imports new commands and appends typed commands to history as they
    # are entered (this replaces inc_append_history, which the manual says
    # to turn off together with share_history).
    setopt share_history

    alias zhistory="builtin history -di 1"

    # Use Emacs key bindings explicitly; otherwise zle picks vi bindings
    # whenever $EDITOR or $VISUAL contains "vi".
    bindkey -e

    # Let ^S reach zle instead of stopping terminal output.
    unsetopt flow_control

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

# Git plugins are pinned with ver"<commit>"; zinit checks it out on clone and
# pulls exactly that commit on zinit update. Bump the hashes deliberately.
if ! shell::is_dumb; then
    zinit ice ver"4b23ecd62a9ad79ddf2ac03c0bd8a7b43266508c"
    zinit light zsh-users/zsh-completions
fi

zshrc::zinit_bundles() {
    zinit snippet OMZP::command-not-found
    zinit snippet OMZP::extract
    zinit snippet OMZP::dircycle
    # Only useful where GNU tools are installed with a g prefix.
    os::is_darwin && zinit snippet OMZP::gnu-utils

    local binaries=(brew cp cpanm fasd gem helm keychain kubectl
                    man minikube mosh nmap node npm perl pip podman
                    python redis-cli rsync ruby sbt scala ssh-agent
                    sudo svn systemd)
    local binary
    for binary in "${binaries[@]}"; do
        path::has_binary "${binary}" && zinit snippet OMZP::${binary}
    done

    if path::has_binary go; then
        zinit snippet OMZP::golang
    fi

    if path::has_binary tmux; then
        zinit snippet OMZP::tmuxinator
    fi

    if path::has_binary git; then
        zinit snippet OMZP::git
        zinit snippet OMZP::gitignore
    fi

    # Completion for the GitHub CLI. (OMZP::github, for the legacy hub CLI,
    # is deprecated and warns on every start.)
    if path::has_binary gh; then
        zinit snippet OMZP::gh
    fi

    if path::has_binary hg; then
        zinit snippet OMZP::mercurial
    fi

    if os::is_darwin; then
        # OMZP::osx was renamed upstream (osx.plugin.zsh no longer exists).
        # macos.plugin.zsh sources its music and spotify helpers from its own
        # directory, which zinit does not fetch for a single-file snippet.
        zinit ice atclone'local f; for f in music spotify; do curl -fsSL -o "${f}" "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/macos/${f}"; done' \
            atpull'%atclone'
        zinit snippet OMZP::macos
    fi
}
shell::is_dumb || shell::eval zshrc::zinit_bundles

zshrc::prompt() {
    # Pure ships its own copy of zsh-async; pick loads it before pure.zsh.
    zinit ice ver"cc0759a0de620f191510e2e2f9748194a605b54d" \
        pick"async.zsh" src"pure.zsh"
    zinit light sindresorhus/pure

    # Single line prompt. Pure only reads this in the current shell, so keep
    # it out of the environment.
    typeset -g +x prompt_newline='%666v'
    PROMPT=" $PROMPT"
}
shell::is_dumb || shell::eval zshrc::prompt

zshrc::completion() {
    # The global compinit in /etc/zsh/zshrc is skipped (skip_global_compinit
    # in .zshenv) so that completion is initialized after zinit has extended
    # fpath, then the compdef calls zinit captured from plugins are replayed.
    autoload -Uz compinit && compinit
    zinit cdreplay -q

    # Some OMZ plugins (kubectl) truncate and regenerate their cached
    # completion in the background on every start, so compinit can find the
    # file empty. Register any cached completion it missed; the function is
    # autoloaded on first use, by when the file is complete.
    local completion
    for completion in "${ZSH_CACHE_DIR}"/completions/_*(N:t); do
        if (( ! ${+_comps[${completion#_}]} )); then
            autoload -Uz "${completion}"
            compdef "${completion}" "${completion#_}"
        fi
    done
}
shell::is_dumb || shell::eval zshrc::completion

if ! shell::is_dumb; then
    zinit ice ver"1d85c692615a25fe2293bdd44b34c217d5d2bf04"
    zinit light zsh-users/zsh-syntax-highlighting
fi

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

if ((PROFILE)); then
    zprof
fi
