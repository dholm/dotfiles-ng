python::path() {
    local version=$(( ${1} )); shift

    local pypath="\${PYTHON${version}PATH}"
    eval echo ${pypath}
}

python::exec_python_version() {
    local version=$(( ${1} )); shift

    local pyenv; pyenv=( PYTHONPATH="$(python::path ${version})" )
    local pybin="$(path::to python${version})"
    shell::exec_env $(shell::as_array pyenv) "${pybin}" "${@}"
}

python::exec_pip_version() {
    local version=$(( ${1} )); shift

    local pipenv; pipenv=(
        PIP_REQUIRE_VIRTUALENV=false
        PYTHONPATH="$(python::path ${version})"
    )
    local pipbin="$(path::to pip${version})"
    shell::exec_env $(shell::as_array pipenv) "${pipbin}" "${@}"
}

python::upgrade_all() {
    local version=$(( ${1:-3} ))

    local pyenv; pyenv=(
        PIP_REQUIRE_VIRTUALENV=false
        PYTHONPATH="$(python::path ${version})"
    )

    # pip.get_installed_distributions() was removed in pip 10. Only upgrade
    # what is installed in the user site, never the distribution's packages.
    local pybin="$(path::to python${version})"
    shell::exec_env $(shell::as_array pyenv) "${pybin}" - <<'EOF'
import site
import subprocess
import sys
from importlib.metadata import distributions

user_site = site.getusersitepackages()
names = sorted({d.metadata["Name"] for d in distributions(path=[user_site])})
if names:
    sys.exit(subprocess.call(
        [sys.executable, "-m", "pip", "install", "--user", "--upgrade", *names]))
EOF
}

python::_site_path() {
    local python="${1}"

    local version="$(${python} --version 2>&1)"
    version="$(string::word 2 "${version}")"
    version="$(compat::version_norm "1.0" "${version}")"

    echo "python${version}/site-packages"
}

python::_setup_darwin() {
    if path::has_binary brew; then
        local libdir="$(homebrew::prefix)/lib"

        if path::has_binary python2; then
            local site2_packages="${libdir}/$(python::_site_path "$(path::to python2)")"
            if file::is_directory ${site2_packages}; then
                export PYTHON2PATH="${site2_packages}:${PYTHON2PATH}"
            fi
        fi

        if path::has_binary python3; then
            local site3_packages="${libdir}/$(python::_site_path "$(path::to python3)")"
            if file::is_directory ${site3_packages}; then
                export PYTHON3PATH="${site3_packages}:${PYTHON3PATH}"
            fi
        fi
    fi
}

python::_setup_pip() {
    export PIP_REQUIRE_VIRTUALENV=true
    export PIP_DOWNLOAD_CACHE="$HOME/.cache/pip"

    export PIPAPP_DIR="${HOME}/.local/libexec/pip-apps"
    $(shell::source "${HOME}/.dotfiles/external/pip-app/pip-app.sh")
    # pip-app.sh prepends its bin directory unconditionally.
    file::is_directory "${PIPAPP_DIR}/bin" || path::remove "${PIPAPP_DIR}/bin"

    path::has_binary pip2 && alias::add syspip2 "python::exec_pip_version 2"
    path::has_binary pip3 && alias::add syspip3 "python::exec_pip_version 3"

    if path::has_binary pip2; then
        alias::add syspip syspip2
    elif path::has_binary pip3; then
        alias::add syspip syspip3
    fi
}

python::_setup_zsh() {
    if os::is_darwin; then
        if path::has_binary brew; then
            local zpython_path="$(homebrew::prefix)/lib/zpython"
            module_path=( ${module_path} ${zpython_path} )
        fi
        zmodload zsh/zpython &>/dev/null
    else
        zmodload libzpython &>/dev/null
    fi
}

python::setup() {
    export VIRTUALENV_DISTRIBUTE=true

    export PYTHON2PATH
    export PYTHON3PATH

    os::is_darwin && python::_setup_darwin
    path::has_binary pip && python::_setup_pip

    shell::is_zsh && python::_setup_zsh

    local pystartup="${HOME}/.pystartup"
    if file::is_readable "${pystartup}"; then
        export PYTHONSTARTUP="${pystartup}"
    fi
}
shell::eval python::setup
