#!/bin/bash

USER=$(dialog --inputbox "Введите имя пользователя GitHub:" 10 40 3>&1 1>&2 2>&3)
repos=$(curl -s "https://api.github.com/users/$USER/repos?per_page=100" | jq -r '.[].name')

if [ -z "$repos" ]; then
    dialog --msgbox "Нет репозиториев у пользователя $USER" 10 40
    clear
    exit 1
fi

options=()
for repo in $repos; do
    options+=("$repo" "")
done

repo=$(dialog --clear --title "Выбор репозитория" --menu "Репозитории $USER:" 20 60 15 "${options[@]}" 3>&1 1>&2 2>&3)

clear
echo "$repo"
