mount::is_point_valid() {
    local mount_point="${1}"

    if (! file::is_directory "${mount_point}" ); then
        print::error "Mount point is not a directory: ${mount_point}!"
        return 1
    fi

    if (mountpoint -q "${mount_point}"); then
        print::error "Mount point already in use: ${mount_point}!"
        return 1
    fi

    return 0
}

mount::sshfs() {
    local user="${1}"
    local host="${2}"
    local remote_path="${3}"
    local mount_point="${4}"

    if (! mount::is_point_valid ${mount_point} ); then
        return 1
    fi

    local sshfs_opts="cache=yes"
    sshfs_opts="${sshfs_opts},kernel_cache"
    sshfs_opts="${sshfs_opts},cache_timeout=60"

    sshfs_opts="${sshfs_opts},compression=no"
    sshfs_opts="${sshfs_opts},large_read"
    sshfs_opts="${sshfs_opts},Ciphers=arcfour"

    sshfs_opts="${sshfs_opts},intr"
    sshfs_opts="${sshfs_opts},reconnect"

    shell::exec "$(path::to sshfs)" "${user}@${host}:${remote_path}" "${mount_point}" -o "${sshfs_opts}"
}
