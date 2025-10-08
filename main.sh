#!$PREFIX/usr/bin/env bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_github_token() {
    # securely get the token
    local token
    token=$("$SCRIPT_DIR/scripts/token.sh" get_token)
    if [ $? -ne 0 ]; then
        echo "Error: Could not retrieve GitHub token" >&2
        return 1
    fi
}

get_username() {
    username=$(dialog --inputbox "Введите имя пользователя GitHub:" 10 40 3>&1 1>&2 2>&3)
}

get_repos() {
    repos=$(curl -s "https://api.github.com/users/$username/repos?per_page=100" | jq -r '.[].name')

    if [ -z "$repos" ]; then
        dialog --msgbox "Нет репозиториев у пользователя $username" 10 40
        clear
        exit 1
    fi

    # Создаем массив опций для dialog
    options=()
    counter=1
    while IFS= read -r repo_name; do
        options+=("$counter" "$repo_name")
        ((counter++))
    done <<< "$repos"

    repo=$(dialog --clear --title "Выбор репозитория" --menu "Репозитории $username:" 20 60 15 "${options[@]}" 3>&1 1>&2 2>&3)
    clear
    
    if [ -n "$repo" ]; then
        selected_repo="${options[$(((repo - 1) * 2 + 1))]}"
        echo "$selected_repo"
    else
        echo "Выбор репозитория отменен"
        exit 1
    fi
}

what_you_want_do_with_repo() {
    action=$(dialog --clear --title "Действие с репозиторием" --menu "Выберите действие для репозитория $REPO:" 15 50 5 \
        1 "Просмотреть информацию о репозитории" \
        2 "Клонировать репозиторий" \
        3 "Выйти" \
        3>&1 1>&2 2>&3)
    clear
    case $action in
        1) view_repo_info ;;
        2) clone_repo ;;
        3) exit 0 ;;
        *) dialog --msgbox "Неверный выбор" 10 40 ;;
    esac
}

view_repo_info() {
    info=$(curl -s "https://api.github.com/repos/$USER/$REPO")
    dialog --msgbox "$info" 20 60
    clear
}

clone_repo() {
    git clone https://www.github.com/$username/$REPO.git
    if [ $? -eq 0 ]; then
        dialog --msgbox "Репозиторий $REPO успешно клонирован."
    else
        dialog --msgbox "Ошибка при клонировании репозитория $REPO."
    fi
    clear
}
main() {
    # вызываем весь этот цирк
    get_github_token || { echo "failed to receive token" >&2; exit 1; }
    get_username || { echo "failed to receive username" >&2; exit 1; }
    get_repos || { echo "failed to receive repos" >&2; exit 1; }
    what_you_want_do_with_repo || { echo "failed to perform action" >&2; exit 1;}
}

main "$@"