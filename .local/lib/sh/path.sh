path::remove() {
    local dir="${1}"

    print::debug "Removing '${dir}' from path"

    if shell::is_zsh; then
        # Remove every occurrence; (b) matches the directory literally.
        path=( "${(@)path:#${(b)dir}}" )
    elif shell::is_bash; then
        local entries; entries=()
        local kept; kept=()
        local entry
        IFS=':' read -r -a entries <<< "${PATH}"
        for entry in "${entries[@]}"; do
            [[ "${entry}" == "${dir}" ]] || kept+=( "${entry}" )
        done
        local IFS=':'
        PATH="${kept[*]}"
    fi
}

path::_is_usable() {
    local dir="${1}"

    # An empty or relative entry makes the shell search the current
    # directory, and a missing one only slows down command lookup.
    if [[ "${dir}" != /* ]]; then
        print::debug "Ignoring relative or empty directory '${dir}'"
        return 1
    fi
    if [[ ! -d "${dir}" ]]; then
        print::debug "Ignoring missing directory '${dir}'"
        return 1
    fi
    return 0
}

path::prepend() {
    local dir="${1}"

    print::debug "Prepending '${dir}' to path"
    path::_is_usable "${dir}" || return 1

    if path::exists "${dir}"; then
        path::remove "${dir}"
    fi

    if shell::is_zsh; then
        path[1,0]="${dir}"
    elif shell::is_bash; then
        if [[ ":$PATH:" != *":${dir}:"* ]]; then
            PATH="${dir}:${PATH+"$PATH"}"
        fi
    fi
}

path::append() {
    local dir="${1}"

    print::debug "Appending '${dir}' to path"
    path::_is_usable "${dir}" || return 1

    path::remove "${dir}"
    if shell::is_zsh; then
        path+="${dir}"
    elif shell::is_bash; then
        if [[ ":$PATH:" != *":${dir}:"* ]]; then
            PATH="${PATH+"$PATH"}:${dir}"
        fi
    fi
}

path::dedupe() {
    print::debug "Removing duplicate and empty entries from path"

    if shell::is_zsh; then
        path=( ${path} )
        typeset -gU path
    elif shell::is_bash; then
        local entries; entries=()
        local result=""
        local entry
        IFS=':' read -r -a entries <<< "${PATH}"
        for entry in "${entries[@]}"; do
            [[ -n "${entry}" ]] || continue
            [[ ":${result}:" == *":${entry}:"* ]] && continue
            result="${result:+${result}:}${entry}"
        done
        PATH="${result}"
    fi
}

path::has_binary() {
    local binary="${1}"

    if shell::is_zsh; then
        return $((1 - $+commands[${binary}]))
    elif shell::is_bash; then
        hash "${binary}" &>/dev/null
    fi
}

path::to() {
    local binary="${1}"

    if shell::is_zsh; then
        echo $commands[${binary}]
    elif shell::is_bash; then
        which "${binary}"
    fi
}

path::exists() {
    local dir="${1}"
    [[ ":$PATH:" == *":${dir}:"* ]]
}
