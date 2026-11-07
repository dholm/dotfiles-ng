array::find() {
    # ${1} names the array to search, see shell::as_array.
    local haystack
    if shell::is_zsh; then
        haystack=( "${(@P)1}" )
    else
        haystack=( "${!1}" )
    fi
    shift
    local needle="${1}"

    # Print the index using the shell's own convention (1-based in zsh,
    # 0-based in bash) so that it can be used to subscript the array.
    local i; i=0
    shell::is_zsh && i=1
    local element
    for element in "${haystack[@]}"; do
        if [[ "${element}" == "${needle}" ]]; then
            echo "${i}"
            return 0
        fi
        i=$(( i + 1 ))
    done

    return 1
}
