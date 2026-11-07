nodejs::setup() {
    # npm's global prefix defaults to the prefix node is installed in, whose
    # bin directory is already in PATH (and for a distribution node, that is
    # /usr/bin, which must not be moved to the front). Only a configured
    # prefix has to be added, so read it instead of starting npm, which is
    # slow.
    local prefix="${NPM_CONFIG_PREFIX:-${npm_config_prefix:-}}"
    if [[ -z "${prefix}" && -r "${HOME}/.npmrc" ]]; then
        prefix="$(sed -n 's/^[[:space:]]*prefix[[:space:]]*=[[:space:]]*//p' "${HOME}/.npmrc" | tail -n 1)"
    fi
    if [[ -n "${prefix}" ]]; then
        prefix="${prefix/#\~/${HOME}}"
        prefix="${prefix//\$\{HOME\}/${HOME}}"
        # Never move a directory that is already in PATH (e.g. /usr/bin).
        path::exists "${prefix}/bin" || path::prepend "${prefix}/bin"
    fi
}
shell::eval nodejs::setup
