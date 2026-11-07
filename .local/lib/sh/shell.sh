. "$HOME/.local/lib/sh/print.sh"

shell::name() {
    shell::exec /bin/ps -p $$ -ocomm=
}

shell::is_zsh() {
    test -n "${ZSH_VERSION}"
}

shell::is_bash() {
    test -n "${BASH_VERSION}"
}

export callee
export caller
export this
if shell::is_zsh; then
    callee='echo ${funcstack[2]}'
    caller='echo ${funcstack[3]}'
    this='echo ${0:-${_}}'
elif shell::is_bash; then
    callee='echo ${FUNCNAME[0]}'
    caller='echo ${FUNCNAME[1]}'
    this='echo ${BASH_SOURCE[0]:-${_}}'
fi

shell::is_non_interactive() {
    [[ $- != *i* ]]
}

shell::is_dumb() {
    shell::is_non_interactive || [[ "${TERM:=dumb}" == "dumb" ]]
}

shell::has_function() {
    local name="${1}"
    if shell::is_zsh; then
        local t="$(type ${name})"
        echo ${t} | grep -q function
    elif shell::is_bash; then
        local t="$(shell::eval type -t "${name}")"
        [[ "${t}" == "function" ]]
    fi
}

shell::as_array() {
    local name="${1}"
    if shell::is_zsh; then
        echo "${name}"
    elif shell::is_bash; then
        echo "${name}[@]"
    fi
}

shell::from_array() {
    local param="${1}"

    if shell::is_bash; then
        echo "echo \${!${param}}"
    elif shell::is_zsh; then
        echo "echo \${(P)\${${param}}[@]}"
    fi
}

shell::eval() {
    print::debug "(${*}): Begin"
    if ((1 == ${#})); then
        # A single argument is shell code (or a function name) to evaluate.
        eval "${1}"
    else
        # A command and its arguments are run as-is so that quoting is
        # preserved.
        "${@}"
    fi
    local retval="$?"
    print::debug "(${*}): End (${retval})"
    return ${retval}
}

shell::source() {
    local file="${1}"; shift
    local qfile; printf -v qfile '%q' "${file}"
    local qargs; qargs=""
    if ((0 < ${#})); then
        printf -v qargs ' %q' "${@}"
    fi

    # Meant to be used as $(shell::source …) so that the file is sourced in
    # the scope of the caller. Every word is quoted with %q so that it
    # survives the word splitting of the unquoted command substitution.
    echo "eval if file::is_readable ${qfile}; then" \
         "print::debug file=${qfile} args={${qargs}}: Begin;" \
         "source ${qfile}${qargs};" \
         "print::debug file=${qfile} args={${qargs}}: End;" \
         "fi"
}

shell::pushd() {
    pushd "${1}" >/dev/null
}
shell::popd() {
    popd >/dev/null
}

shell::exec_env() {
    # ${1} names an array of VAR=value assignments, see shell::as_array.
    local env
    if shell::is_zsh; then
        env=( "${(@P)1}" )
    else
        env=( "${!1}" )
    fi
    shift

    print::debug "(env={${env[*]}} cmd={${*}}): Begin"
    /usr/bin/env "${env[@]}" "${@}"
    local retval="${?}"
    print::debug "(env={${env[*]}} cmd={${*}}): End (${retval})"
    return ${retval}
}

shell::exec() {
    local nil_env; nil_env=( )
    shell::exec_env $(shell::as_array nil_env) "${@}"
}

shell::args_parse() {
    local short="${1}"; shift
    local long="${1}"; shift

    print::debug "short=${short} long=${long}"
    local cmd="getopt"
    if os::is_darwin; then
        cmd="$(brew --prefix gnu-getopt)/bin/getopt"
    fi

    local get_opts="${cmd} -o ${short} --long ${long} -n $(eval ${caller})"
    echo "eval set -- \$(${get_opts} -- \"\${@}\")"
}

shell::bindings() {
    local keymap="${1:-}"

    if shell::is_bash; then
        local args=( -p )
        if [ -n "${keymap}" ]; then
            args+=( -m "${keymap}" )
        fi
        bind ${args[@]}
    elif shell::is_zsh; then
        if [ -n "${keymap}" ]; then
            bindkey -M "${keymap}"
        else
            print::error "No keymap specified!"
        fi
    fi
}
