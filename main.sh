#!$PREFIX/usr/bin/env bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_github_token() {
    # securely get the token
    local token
    token=$("$SCRIPT_DIR/scripts/n.sh" get_token)
    if [ $? -ne 0 ]; then
        echo "Error: Could not retrieve GitHub token" >&2
        return 1
    fi
}

main() {
    get_github_token || { echo "failed to receive token" >&2; exit 1; }

}
}

token "$@"
