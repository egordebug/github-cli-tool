#!/bin/bash

# Secure token storage location
TOKEN_FILE="$HOME/.mygithubcli_token"

# Function to get token securely
get_token() {
    local caller_script
    caller_script=$(ps -o comm= $PPID)
    
    # Only allow access from main.sh
    if [[ "$caller_script" != *"main.sh" ]]; then
        echo "Access denied: Token can only be accessed by main.sh" >&2
        return 1
    fi
    
    if [ -f "$TOKEN_FILE" ]; then
        cat "$TOKEN_FILE"
        return 0
    fi
    return 1
}

check_deps() { command -v dialog >/dev/null || { echo "dialog not found"; exit 1; } }

ask_token() { dialog --insecure --passwordbox "GitHub Token:" 10 60 --stdout; }

verify_token() {
    local token="$1"
    [ -z "$token" ] && return 1
    [ "$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $token" https://api.github.com/user)" -eq 200 ]
}

save_token() { 
    # Create token file with restricted permissions (only owner can read/write)
    umask 077
    echo "$1" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
}

main() {
    check_deps
    local token
    token=$(ask_token)
    clear
    if verify_token "$token"; then
        save_token "$token"
        dialog --msgbox "Authorization successful" 6 40
    else
        dialog --msgbox "Invalid token" 6 40
    fi
    clear
}

case "$1" in
    "ask_token")
        main
        ;;
    "get_token")
        get_token
        ;;
    *)
        echo "Usage: $0 {ask_token|get_token}"
        ;;
esac
