fn::map() {
    local fn="${1}"; shift
    fn::_map() {
        eval echo ${fn}
    }
    local x
    for x in ${@}; do
        fn::_map ${x}
    done
}

fn::mapa() {
    local fn="\$(( ${1} ))"; shift
    fn::map "${fn}" "${@}"
}

fn::fold() {
    local fn="${1}"; shift
    local acc="${1}"; shift

    fn::_fold() {
        local acc="${1}"
        local x="${2}"
        eval ${fn}
    }
    fn::_fold_helper() {
        acc=$(fn::_fold "${acc}" "${1}")
    }
    local x
    for x in ${@}; do
        fn::_fold_helper ${x}
    done
    echo ${acc}
}

fn::foldf() {
    local fn="echo \$(${1} \${acc} \${x})"; shift
    fn::fold "${fn}" "${@}"
}

fn::folda() {
    local fn="echo \$(( ${1} ))"; shift
    fn::fold "${fn}" "${@}"
}

fn::foldr() {
    local fn="${1}"; shift
    local acc="${1}"; shift
    fn::_foldr() {
        local x="${1}"
        local acc="${2}"
        eval ${fn}
    }
    local input
    input=( )
    fn::_foldr_storer() {
        input+=( ${1} )
    }
    local x
    for x in ${@}; do
        fn::_foldr_storer ${x}
    done

    # Walk the elements from the last to the first (not the characters, as
    # piping through rev did).
    local n
    for (( n = ${#input[@]}; n > 0; n-- )); do
        x="${input[@]:$(( n - 1 )):1}"
        acc=$(fn::_foldr ${x} "${acc}")
    done
    echo ${acc}
    return 0
}

fn::filter() {
    local fn="${1}"; shift

    fn::_filter() {
        local x="${1}"
        eval "${fn}" && echo "${x}"
    }
    local x
    for x in ${@}; do
        fn::_filter ${x}
    done
    return 0
}

fn::filterf() {
    local fn="${1} \"\$x\""; shift
    fn::filter "${fn}" "${@}"
}

fn::filtera() {
    local fn="(( ${1} ))"; shift
    fn::filter "${fn}" "${@}"
}

fn::each() {
    local fn="${1}"; shift
    fn::_each() {
        eval ${fn}
    }
    local x
    for x in ${@}; do
        fn::_each ${x}
        local retval="${?}"
        (( ${retval} != 0 )) && return ${retval}
    done
    return 0
}

fn::eachf() {
    local fn="${1} \"\${1}\""; shift
    fn::each "${fn}" "${@}"
}
