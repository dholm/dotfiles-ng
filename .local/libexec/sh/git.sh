vcs::git::subpatch_list() {
    local base_path="${1}"

    local reflist
    reflist="$(shell::exec "$(path::to git)" log --format=%h --reverse -- "${base_path}")"
    if [ "${?}" -ne 0 ]; then
        print::error "Failed to generate list of refspecs for ${base_path}!"
        return 1
    fi

    if [[ -n "${reflist}" ]]; then
        printf '%s\n' "${reflist}"
    fi
}

vcs::git::subpatch_generate() {
    local base_path="${1}"
    local out_path="${2}"

    local refspec_list; refspec_list=( $(vcs::git::subpatch_list ${base_path}) )
    # -1 <commit> instead of <commit>~1..<commit>, which fails for a root
    # commit.
    local git_args; git_args=( log -p --pretty=email --stat -m -1 )
    local refspec
    local patch
    for refspec in ${refspec_list[@]}; do
        patch="$(shell::exec "$(path::to git)" "${git_args[@]}" "${refspec}" -- "${base_path}")"
        if [ "${?}" -ne 0 ]; then
            print::warning "Failed to generate patch for ${refspec}!"
            continue
        fi
        local patch_file="${out_path}/${refspec}.patch"
        # printf, not echo: zsh's echo interprets backslashes and bash's
        # unquoted expansion split and globbed the patch.
        printf '%s\n' "${patch}" >"${patch_file}"
    done

    printf '%s\n' "${refspec_list[@]}" >"${out_path}/patch.list"
}

vcs::git::subpatch_apply() {
    local patch_list_file="${1}"
    local strip_prefix="${2}"

    local patch_path="$(shell::exec "$(path::to dirname)" "${patch_list_file}")"
    local patch_list; patch_list=( $(cat "${patch_list_file}") )
    local git_args; git_args=( am -3 "-p${strip_prefix}" )
    local refspec
    for refspec in ${patch_list[@]}; do
        local patch_file="${patch_path}/${refspec}.patch"
        shell::exec "$(path::to git)" "${git_args[@]}" "${patch_file}"
        if [ "${?}" -ne 0 ]; then
            print::error "Failed to apply ${patch_file}!"
            return 1
        fi
    done
    return 0
}
