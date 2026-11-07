go::setup() {
    # GOROOT is not set: go finds its own root, and on Darwin an exported
    # $(go env GOROOT) pointed into a versioned Homebrew Cellar directory that
    # disappears on brew upgrade go.
    export GOPATH="${HOME}/Projects/go"
    path::prepend "${GOPATH}/bin"
}
shell::eval go::setup
