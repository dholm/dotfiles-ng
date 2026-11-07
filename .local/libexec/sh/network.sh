_network::ip::public() {
    local url="${1}"

    if path::has_binary curl; then
        shell::exec curl --silent "${url}"
    elif path::has_binary wget; then
        shell::exec wget --quiet --output-document - "${url}"
    else
        return 1
    fi
}

network::ip::public() {
    local usage="Usage:
 -4 --ipv4  - Query the IPv4 address.
 -6 --ipv6  - Query the IPv6 address.
 -h --help  - Print help.
"
    eval $(shell::args_parse "46h" "ipv4,ipv6,help")

    local host="icanhazip.com"
    while true; do
        case "${1}" in
            -4|--ipv4) host="ipv4.icanhazip.com";;
            -6|--ipv6) host="ipv6.icanhazip.com";;
            -h|--help) print::info ${usage}; return 0;;
            --) shift; break;;
            *) print::error "Unknown option: ${1}"; return 1;;
        esac
        shift
    done

    _network::ip::public "https://${host}"
}

network::dns::flush() {
    if os::is_darwin; then
        shell::exec dscacheutil -flushcache
        process::hangup --privileged mDNSResponder
    elif os::is_linux; then
        # Only flush caches that are running; restarting a stopped cache
        # daemon would start it.
        if service::is_running systemd-resolved; then
            shell::exec sudo resolvectl flush-caches
        elif service::is_running dns-clean; then
            service::restart dns-clean
        elif service::is_running nscd; then
            service::restart nscd
        elif service::is_running dnsmasq; then
            service::restart dnsmasq
        elif service::is_running bind; then
            service::restart bind
        fi
    fi
}

network::dns::resolve::ns() {
    local zone="${1%.}"

    # NS records only exist at zone apexes, so walk up from the host name
    # until one is found. Only accept NS records owned by the queried name,
    # not ones reached by following a CNAME.
    local ns
    while [[ -n "${zone}" ]]; do
        ns="$(shell::exec dig +noall +answer NS "${zone}" |
              awk -v zone="${zone}." \
                  'tolower($1) == tolower(zone) && $4 == "NS" { print $5 }')"
        if [[ -n "${ns}" ]]; then
            echo "${ns}"
            return 0
        fi
        [[ "${zone}" == *.* ]] || break
        zone="${zone#*.}"
    done

    return 1
}

network::dns::resolve() {
    local host="${1}"

    local ns; ns=( $(network::dns::resolve::ns ${host}) )
    if [ ${#ns[@]} -eq 0 ]; then
        return 1
    fi

    local dig_args; dig_args=( +short "@${ns[@]:0:1}" )
    shell::exec dig "${dig_args[@]}" "${host}"
}

network::protocol::statistics() {
    shell::exec netstat -s
}

network::dump2pcap() {
    local infile="${1}"
    local outfile="${2}"

    shell::exec text2pcap <(hexdump -v -e '"%06_ax  "16/1 "%02x " "\n"' "${infile}") "${outfile}"
}
