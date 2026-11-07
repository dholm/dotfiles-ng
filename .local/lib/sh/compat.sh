# These libraries need zsh or bash >= 4.2 (associative arrays, typeset -g).
# There is no fallback for older bash versions such as macOS' /bin/bash 3.2.

compat::version() {
    echo "$@" | awk -F. '{ printf("%d.%d.%d\n", $1,$2,$3); }'
}

compat::version_norm() {
    local base="${1}"
    local version="${2}"

    local components=$(( $(string::words "$(string::split . ${base})") ))
    local vsplit; vsplit=( $(string::split . "${version}") )
    local vnorm; vnorm=( ${vsplit[@]:0:${components}} )

    echo "$(string::join . $(shell::as_array vnorm))"
}

compat::shell::is_supported() {
    if shell::is_bash; then
        (( BASH_VERSINFO[0] > 4 ||
           (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) ))
    else
        shell::is_zsh
    fi
}

if ! compat::shell::is_supported; then
    echo "compat.sh: Unsupported shell (bash ${BASH_VERSION:-?});" \
         "these libraries need zsh or bash >= 4.2." 1>&2
fi
