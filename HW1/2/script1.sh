#!/bin/bash

# Список хостов для проверки (доменные имена, IP-адреса и недопустимые)
HOSTS=("ya.ru" "google.com" "mephi.ru" "127.0.0.1" "192.168.1.1" "192.168.1.2" "999.999.999.999")

# Функция для проверки, является ли строка потенциальным IP-адресом
# Проверяется соответсвие строки регулярному выражению X.X.X.X, где X - от 1 до 3 цифр
is_potential_ip_address() {
  [[ "$1" =~ ([0-9]{1,3}\.){3}[0-9]{1,3} ]]
}

# Функция для проверки, является ли строка валидным IP-адресом
# Строка разбивается на 4 подстроки, разделённых точками, потом каждая подстрока проверяется на попадание в диапазон 0-255
# Если все подстроки соответсвуют этому условию, то строка считается валидным IP-адресом
is_valid_ip_address() {
    IFS='.'
    read -r i1 i2 i3 i4 <<< "$1"
    [ "$i1" -ge 0 ] && [ "$i1" -le 255 ] && [ "$i2" -ge 0 ] && [ "$i2" -le 255 ] &&
    [ "$i3" -ge 0 ] && [ "$i3" -le 255 ] && [ "$i4" -ge 0 ] && [ "$i4" -le 255 ]
}

# Переменные для подсчёта доступных и недоступных хостов
AVAILABLE_HOSTS_COUNT=0
UNAVAILABLE_HOSTS_COUNT=0

# Прохождение циклом по всем хостам в списке
for HOST in ${HOSTS[*]}; do
    if is_potential_ip_address "$HOST"; then
        if is_valid_ip_address "$HOST"; then
            # Проверка доступности валидных IP-адресов с помощью ping (3 попытки)
            # Вывод и ошибки ping игноруются
            if ping -c 3 "$HOST" &> /dev/null; then
                echo "Хост $HOST доступен"
                ((AVAILABLE_HOSTS_COUNT++))
            else
                echo "Хост $HOST недоступен"
                ((UNAVAILABLE_HOSTS_COUNT++))
            fi
        else
            echo "$HOST - недопустимый IP-адрес"
            ((UNAVAILABLE_HOSTS_COUNT++))
        fi
    else
        # Проверка доступности доменных имён и прочего с помощью ping (3 попытки)
        # Вывод и ошибки ping игноруются
        if ping -c 3 "$HOST" &> /dev/null; then
            echo "Хост $HOST доступен"
            ((AVAILABLE_HOSTS_COUNT++))
        else
            echo "Хост $HOST недоступен"
            ((UNAVAILABLE_HOSTS_COUNT++))
        fi
    fi
done

# Вывод общего количества доступных и недоступных хостов
echo "Общее количество доступных хостов: $AVAILABLE_HOSTS_COUNT"
echo "Общее количество недоступных хостов: $UNAVAILABLE_HOSTS_COUNT"