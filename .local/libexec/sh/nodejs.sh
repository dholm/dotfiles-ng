nodejs::setup() {
    if path::has_binary npm; then
        path::prepend "$(npm prefix --global)/bin"
    fi
}
shell::eval nodejs::setup
