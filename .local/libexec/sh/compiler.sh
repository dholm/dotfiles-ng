compiler::_dump() {
    local compiler_bin="${1}"; shift

    print::debug "(${compiler_bin} ${*}): Begin"
    echo "main;" | shell::exec "${compiler_bin}" "${@}" -x c - </dev/null 2>&1
    local retval="$?"
    print::debug "(${compiler_bin} ${*}): End (${retval})"

    return ${retval}
}

compiler::dump_defines() {
    local compiler_bin="${1}"; shift

    compiler::_dump "${compiler_bin}" "${@}" -dM -E
}

compiler::dump_flags() {
    local compiler_bin="${1}"; shift

    compiler::_dump "${compiler_bin}" "${@}" -Q -v
}

compiler::dump_includes() {
    local compiler_bin="${1}"; shift

    shell::exec "${compiler_bin}" -w -H "${@}"
}

compiler::find_typedef() {
    local name="${1}"
    local search_path="${2:-/usr/include}"

    shell::exec grep -E -r "typedef.*${name};" "${search_path}"
}

compiler::disassemble_functions() {
    local binary="${1}"; shift

    local args; args=( -nh -batch -quiet -ex "file ${binary}" )
    args+=( -ex "set disassembly-flavor intel" )

    local fun
    for fun in "${@}"; do
        args+=( -ex "disassemble /m ${fun}" )
    done

    shell::exec gdb "${args[@]}"
}
