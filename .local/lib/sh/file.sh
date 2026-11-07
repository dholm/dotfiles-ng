file::abs() {
    local file="${1}"
    if os::is_darwin; then
        shell::exec readlink "${file}"
    else
        shell::exec readlink -e "${file}"
    fi
}

file::is_directory() {
    local directory="${1}"
    test -d "${directory}"
}

file::is_executable() {
    local file="${1}"
    test -x "${file}"
}

file::is_readable() {
    local file="${1}"
    test -r "${file}"
}

file::exists() {
    local retval=1

    if ((0 < ${#})); then
        # The arguments are glob patterns, so expand them like bash does.
        shell::is_zsh && setopt localoptions globsubst shwordsplit nonomatch
        shell::exec ls -1 ${@} 2>/dev/null
        retval=${?}
    fi

    return ${retval}
}
