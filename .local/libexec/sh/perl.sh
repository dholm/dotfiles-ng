perl::_archname() {
    # Sets REPLY to perl's archname. Running perl for it costs a few ms on
    # every shell start, and the archname of a given perl binary does not
    # change, so it is cached per perl path. Delete the cache file to refresh.
    local perl_bin
    if shell::is_zsh; then
        perl_bin="${commands[perl]}"
    else
        hash perl 2>/dev/null
        perl_bin="${BASH_CMDS[perl]}"
    fi

    local cache="${XDG_CACHE_HOME:-${HOME}/.cache}/shellrc/perl-archname"
    local cached_bin cached_arch
    if [[ -r "${cache}" ]] &&
           IFS=$'\t' read -r cached_bin cached_arch <"${cache}" &&
           [[ "${cached_bin}" == "${perl_bin}" && -n "${cached_arch}" ]]; then
        REPLY="${cached_arch}"
        return 0
    fi

    REPLY="$(perl -MConfig -e 'print $Config{archname}')" || return 1
    mkdir -p "${cache%/*}" &&
        printf '%s\t%s\n' "${perl_bin}" "${REPLY}" >"${cache}"
}

perl::local_lib::setup() {
    perl::_archname
    local arch_name="${REPLY}"

    export PERL_LOCAL_LIB_ROOT="${HOME}/.local"
    export PERL_MB_OPT="--install_base ${PERL_LOCAL_LIB_ROOT}"
    export PERL_MM_OPT="INSTALL_BASE=${PERL_LOCAL_LIB_ROOT} LIB=${PERL_LOCAL_LIB_ROOT}/lib"
    export PERL_MM_OPT="${PERL_MM_OPT} INSTALLSITEMAN1DIR=${PERL_LOCAL_LIB_ROOT}/share/man/man1"
    export PERL_MM_OPT="${PERL_MM_OPT} INSTALLSITEMAN3DIR=${PERL_LOCAL_LIB_ROOT}/share/man/man3"
    export PERL5LIB="${PERL_LOCAL_LIB_ROOT}/lib/perl5/${arch_name}:${PERL_LOCAL_LIB_ROOT}/lib/perl5"
}

perl::setup() {
    # Append rather than prepend, so these scripts cannot shadow ~/bin or
    # ~/.local/bin.
    path::append "${HOME}/perl5/bin"

    shell::eval perl::local_lib::setup

    local perlbrew_init="${HOME}/perl5/perlbrew/etc/bashrc"
    if file::is_readable "${perlbrew_init}"; then
        $(shell::source "${perlbrew_init}")
    fi
}
shell::eval perl::setup
