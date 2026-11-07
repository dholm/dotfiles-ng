profile::start() {
    local sed="sed -u"
    local date="date"
    if os::is_darwin; then
        sed="sed"
        date="$(brew --prefix)/bin/gdate"
    fi

    # A private directory instead of predictable /tmp/$USER-shellrc.$$ names,
    # which another user could pre-create or symlink.
    _profile_dir="$(mktemp -d "${TMPDIR:-/tmp}/shellrc-profile-XXXXXXXX")" || return 1
    _profile_sample="${_profile_dir}/shellrc"

    exec 3>&2 2> >(
        tee "${_profile_sample}.log" |
            ${sed} 's/^.*$/now/' |
            ${date} -f - +%s.%N >"${_profile_sample}.tim"
    )
    if shell::is_bash; then
        export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
        set -x
    elif shell::is_zsh; then
        setopt xtrace prompt_subst
    fi
}

profile::stop() {
    if shell::is_bash; then
        set +x
    elif shell::is_zsh; then
        unsetopt xtrace
    fi
    exec 2>&3 3>&-
    print::info "Profile written to ${_profile_sample}.log, run: profile::report ${_profile_sample}.log"
}

profile::report() {
    # Accepts the sample's .log or .tim file, or the path without suffix.
    local sample_file="${1%.log}"
    sample_file="${sample_file%.tim}"

    paste <(
        while read tim ;do
            [ -z "$last" ] && last=${tim//.} && first=${tim//.}
            crt=000000000$((${tim//.}-10#0$last))
            ctot=000000000$((${tim//.}-10#0$first))
            printf "%12.9f %12.9f\n" \
                ${crt:0:${#crt}-9}.${crt:${#crt}-9} \
                ${ctot:0:${#ctot}-9}.${ctot:${#ctot}-9}
            last=${tim//.}
      done < ${sample_file}.tim
    ) ${sample_file}.log \
        | string::filter_escape \
        | awk '{
              if (min=="") {min=max=$1};
              if ($1>max) {max=$1};
              if($1<min) {min=$1};
              total+=$1;
              count+=1;
              print$0;
            }
            END {
              print "--------------------------"
              printf "avg=%12.9f max=%12.9f min=%12.9f", total/count, max, min
            }'
}

if ((PROFILE)); then
    profile::start
fi
