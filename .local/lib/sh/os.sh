# $OSTYPE is set by both zsh and bash, so no uname fork is needed.

os::is_linux() {
    [[ "${OSTYPE}" == linux* ]]
}

os::is_darwin() {
    [[ "${OSTYPE}" == darwin* ]]
}
