. "${HOME}/.shellrc"


# The rest only matters for interactive shells. .bash_profile also sources
# this file for non-interactive login shells (bash -lc, commands over ssh),
# which only need the environment set up by .shellrc.
if shell::is_non_interactive; then
    if ((PROFILE)); then
        profile::stop
    fi
    return 0
fi


_bashrc_liquidprompt="${HOME}/.dotfiles/external/liquidprompt/liquidprompt"


bashrc::bash_it() {
    # Path to the bash it configuration
    export BASH_IT="${HOME}/.bash.d/bash_it"

    # Liquidprompt (loaded below) replaces the prompt, so only load a bash-it
    # theme when it is missing.
    if file::is_readable "${_bashrc_liquidprompt}"; then
        export BASH_IT_THEME=''
    else
        export BASH_IT_THEME='bobby'
    fi

    # Load Bash It
    $(shell::source $BASH_IT/bash_it.sh)

    # Load selection of bash-it plugins
    local plugins; plugins=(
        base dirs fasd git python ssh tmux tmuxinator
    )
    os::is_darwin && plugins+=( osx )

    # Enabled plugins are symlinks named <priority>---<name>.plugin.bash.
    # Checking for them is much faster than 'bash-it show plugins', and
    # matches whole names only.
    local plugin
    for plugin in "${plugins[@]}"; do
        if ! compgen -G "${BASH_IT}/enabled/*---${plugin}.plugin.bash" >/dev/null; then
            shell::eval bash-it enable plugin "${plugin}"
        fi
    done
    if ! os::is_darwin &&
            compgen -G "${BASH_IT}/enabled/*---osx.plugin.bash" >/dev/null; then
        shell::eval bash-it disable plugin osx
    fi
}
shell::is_dumb || shell::eval bashrc::bash_it


bashrc::history() {
    # Don't put duplicate lines or lines starting with space in the history.
    HISTCONTROL=ignoreboth
    # Increase length of history, matching zsh.
    HISTSIZE=100000
    HISTFILESIZE=${HISTSIZE}
    export -n HISTSIZE HISTFILESIZE

    # Append to the history file, don't overwrite it.
    shopt -s histappend
}
shell::eval bashrc::history


bashrc::liquidprompt() {
    $(shell::source "${_bashrc_liquidprompt}")
}
shell::is_dumb || shell::eval bashrc::liquidprompt


$(shell::source "${HOME}/.bashrc.local")
$(shell::source "${HOME}/.bash_aliases.local")


if ((PROFILE)); then
    profile::stop
fi
