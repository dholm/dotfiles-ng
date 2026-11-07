# Colours and styles are plain ANSI SGR sequences, so printing a message does
# not fork tput, and they are only used when stderr is a terminal.

print::_sgr() {
    printf '\033[%sm' "${1}"
}

print::pen_color() {
    local fg_bg="${1}"
    local color="${2}"

    case "${color}" in
        black) color=0;;
        red) color=1;;
        green) color=2;;
        yellow) color=3;;
        blue) color=4;;
        magenta) color=5;;
        cyan) color=6;;
        white) color=7;;
    esac

    case "${fg_bg}" in
        fg) print::_sgr "3${color}";;
        *) print::_sgr "4${color}";;
    esac
}

print::pen_style() {
    local style="${1}"

    case "${style}" in
        normal) print::_sgr 0;;
        standout) print::_sgr 7;;
        bold) print::_sgr 1;;
        dim) print::_sgr 2;;
        reverse) print::_sgr 7;;
        blink) print::_sgr 5;;
        underline) print::_sgr 4;;
        hidden) print::_sgr 8;;
    esac
}

print::_message() {
    # ${1}: SGR parameters, ${2}: name of the calling function, rest: message.
    local sgr="${1}"
    local name="${2}"
    shift 2

    if [[ -t 2 && "${TERM:-dumb}" != "dumb" ]]; then
        printf '\033[%sm%s:%b\033[0m\n' "${sgr}" "${name}" "${*}" 1>&2
    else
        printf '%s:%b\n' "${name}" "${*}" 1>&2
    fi
}

print::error() {
    local name
    if [[ -n "${ZSH_VERSION}" ]]; then name="${funcstack[2]}"; else name="${FUNCNAME[1]}"; fi
    print::_message "1;31" "${name}" "${@}"
}

print::warning() {
    local name
    if [[ -n "${ZSH_VERSION}" ]]; then name="${funcstack[2]}"; else name="${FUNCNAME[1]}"; fi
    print::_message "33" "${name}" "${@}"
}

print::info() {
    local name
    if [[ -n "${ZSH_VERSION}" ]]; then name="${funcstack[2]}"; else name="${FUNCNAME[1]}"; fi
    print::_message "32" "${name}" "${@}"
}

print::debug() {
    if ((DEBUG)); then
        local name
        if [[ -n "${ZSH_VERSION}" ]]; then name="${funcstack[2]}"; else name="${FUNCNAME[1]}"; fi
        print::_message "37" "${name}" "${@}"
    fi
}
