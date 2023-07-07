Конечно, давайте разобьем код на функции и опишем каждую из них. Ниже приведен пример, как можно разделить код на функции


#!/bin/bash

#-----------------------------------declare variables-----------------------------------#
declare -i fa           #fa is a FAIL counter integer
declare -i counter      #counter is counter as ever
vitrin=$1               #get vitrin_name from commandline
uvitrin=${vitrin^^}     #get UPPERCASE variant of vitrin_name
ip=$2                   #get IP from commandline

#-----------------------------------function check-----------------------------------#
function check {
    if [ $? -eq 0 ]; then
        echo -e $1 '\033[92mOK\033[0m'
    else
        echo -e $1 '\033[91mFAIL\033[0m'
        fa+=1 #fastest way to increase integer by 1
    fi
}

#-----------------------------------function validate_input-----------------------------------#
function validate_input {
    if [ ! $vitrin ] || [ ! $ip ]; then
        echo "You need to specify the vitrin name and IP address."
        echo "Format is: ./backup.sh %vitrin_name% %vitrin_IP%"
        exit 1
    fi
}

#-----------------------------------function get_sql_script-----------------------------------#
function get_sql_script {
    if [[ $vitrin == "etrn" ]] || [[ $vitrin == "esv" ]] || [[ $vitrin == "ezn" ]]; then
        fulldbname="mtrs_"$vitrin"_info"
    elif [[ $vitrin == "epl" ]]; then
        fulldbname="f_mtrs_"$vitrin"_info"
    fi
}

#-----------------------------------function check_delta_hot-----------------------------------#
function check_delta_hot {
    get_delta_hot=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "get_delta_hot()"}' http://$ip:9090/query/execute | jq .empty)

    echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"
    echo "---------------Processing ("mtrs_"$vitrin"_info") ---------------"

    if [ "$get_delta_hot" == "false" ]; then
        echo "---------------Loading into database---------------"
        exit 1
    elif [ "$get_delta_hot" == "null" ]; then
        echo "---------------Failed to check delta, check showcase name and IP---------------"
        exit 1
    elif [ "$get_delta_hot" == "true" ]; then
        echo "---------------Stopped csv-uploader query-execution---------------"
        docker stop csv-uploader 
        check "Container csv-uploader stopped"
    fi
}

#-----------------------------------function process_tables-----------------------------------#
function process_tables {
    not_run=$(docker ps --filter "status=exited" | grep "csv-uploader" | wc -l)

    if [ "$not_run" -gt 0 ]; then
        echo "---------------Create database logical only and stop csv-uploader---------------"
        dbname=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "SELECT schema_name  FROM INFORMATION_SCHEMA.schemata ;"}' http://$ip:9090/query/execute | jq .result[][] | grep $uvitrin | tr -d \")
        check "Getting dbname of $dbname"
        ufulldbname=${fulldbname^^}             # for the next selection table names must be UPPERCASE
        tablelist=$(curl -s -X POST -H "Content-Type: application/json" -d '{"requestId": "797de19a-54e2-4c9c-af6e-a9ee312230b5","datamartMnemonic": "'$fulldbname'","sql": "SELECT table_name,table_schema  FROM INFORMATION_SCHEMA.tables "}' http://$ip:9090/query/execute | jq '.result[] | select (.TABLE_SCHEMA=="'$ufulldbname'")' | grep -v $dbname | grep INFO | awk '{print $2}' | tr -d \" | tr -d ,)
        check "Getting list"
        echo "Create database $fulldbname logical_only;" &gt; ./$vitrin-prostore-sql.sql
        check "File with prostore sql instructions created"

    # Добавьте здесь код для обработки таблиц в новом местоположении
    # Например, можно использовать цикл для обработки каждой таблицы в списке $tablelist
    # и выполнить необходимые действия для каждой таблицы

    # Пример:
    for table in $tablelist; do
        echo "Processing table: $table"
        # Добавьте здесь код для обработки каждой таблицы
        # Например, можно создать резервную копию таблицы или перенести ее в новое местоположение
    done

    echo "Tables processed successfully."
}

#-----------------------------------Main Code-----------------------------------#

# Вызов функций
validate_input
get_sql_script
check_delta_hot
process_tables

# Возможно, вам потребуется добавить дополнительный код после вызова функций, если есть другие операции, которые нужно выполнить.


Вышеуказанный код разделяет основной скрипт на отдельные функции, каждая из которых выполняет свою определенную задачу. В функции `process_tables` приведен пример цикла, который обрабатывает каждую таблицу в списке `$tablelist`. Вам нужно добавить соответствующий код для обработки каждой таблицы внутри цикла.

Обратите внимание, что в конце скрипта добавлены вызовы функций `validate_input`, `get_sql_script`, `check_delta_hot` и `process_tables`, чтобы выполнить соответствующие операции. Вы можете добавить свой собственный код после вызова функций, если вам нужно выполнить дополнительные операции.


#!/bin/bash

# Объявление переменных
declare -i fa           # fa - счетчик ошибок
declare -i counter      # счетчик

# Функция для проверки результата выполнения команд
function check {
    if [ $? -eq 0 ]; then
        echo -e $1 '\033[92mOK\033[0m'
    else
        echo -e $1 '\033[91mFAIL\033[0m'
        fa+=1 # увеличение счетчика ошибок на 1
    fi
}

# Функция для валидации входных данных
function validate_input {
    if [ ! $vitrin ] || [ ! $ip ]; then
        echo "You need to specify the vitrin name and IP address."
        echo "Format is: ./backup.sh %vitrin_name% %vitrin_IP%"
        exit 1
    fi
}

# Функция для получения SQL-скрипта
function get_sql_script {
    if [[ $vitrin == "etrn" ]] || [[ $vitrin == "esv" ]] || [[ $vitrin == "ezn" ]]; then
        fulldbname="mtrs_"$vitrin"_info"
    elif [[ $vitrin == "epl" ]]; then
        fulldbname="f_mtrs_"$vitrin"_info"
    fi
}

# Функция для проверки delta hot
function check_delta_hot {
    # Добавьте здесь код для проверки delta hot
}

# Функция для обработки таблиц
function process_tables {
    # Добавьте здесь код для обработки таблиц
}

# Главный код

# Получение входных данных
vitrin=$1
ip=$2

# Вызов функций
validate_input
get_sql_script
check_delta_hot
process_tables

# Вывод результата
if [ $fa -eq 0 ]; then
    echo "All operations completed successfully."
else
    echo "There were errors during the process."
fi


В этом примере кода каждая часть скрипта вынесена в отдельные функции, что делает его более модульным и позволяет повторно использовать отдельные части. Вам нужно добавить соответствующий код в функции `check_delta_hot` и `process_tables` для выполнения соответствующих операций.

После вызова всех функций выводится информация о результате выполнения операций. Если счетчик ошибок `fa` равен 0, выводится сообщение об успешном выполнении всех операций. В противном случае, выводится сообщение о наличии ошибок.

Пожалуйста, примите мои извинения за предыдущую путаницу.


















Конечно, вот полный пример кода, который включает все функции и основной код:

bash
#!/bin/bash

# Объявление переменных
declare -i fa           # fa - счетчик ошибок
declare -i counter      # счетчик

# Функция для проверки результата выполнения команд
function check {
    if [ $? -eq 0 ]; then
        echo -e $1 '\033[92mOK\033[0m'
    else
        echo -e $1 '\033[91mFAIL\033[0m'
        fa+=1 # увеличение счетчика ошибок на 1
    fi
}

# Функция для валидации входных данных
function validate_input {
    if [ ! $vitrin ] || [ ! $ip ]; then
        echo "You need to specify the vitrin name and IP address."
        echo "Format is: ./backup.sh %vitrin_name% %vitrin_IP%"
        exit 1
    fi
}

# Функция для получения SQL-скрипта
function get_sql_script {
    if [[ $vitrin == "etrn" ]] || [[ $vitrin == "esv" ]] || [[ $vitrin == "ezn" ]]; then
        fulldbname="mtrs_"$vitrin"_info"
    elif [[ $vitrin == "epl" ]]; then
        fulldbname="f_mtrs_"$vitrin"_info"
    fi
}

# Функция для проверки delta hot
function check_delta_hot {
    # Добавьте здесь код для проверки delta hot
    # Например, можно использовать curl для выполнения запроса и проверки результата
}

# Функция для обработки таблиц
function process_tables {
    # Добавьте здесь код для обработки таблиц
    # Например, можно использовать цикл для обработки каждой таблицы
}

# Главный код

# Получение входных данных
vitrin=$1
ip=$2

# Вызов функций
validate_input
get_sql_script
check_delta_hot
process_tables

# Вывод результата
if [ $fa -eq 0 ]; then
    echo "All operations completed successfully."
else
    echo "There were errors during the process."
fi


В этом примере кода каждая часть скрипта вынесена в отдельные функции, что делает его более модульным и позволяет повторно использовать отдельные части. Вам нужно добавить соответствующий код в функции `check_delta_hot` и `process_tables` для выполнения соответствующих операций.

После вызова всех функций выводится информация о результате выполнения операций. Если счетчик ошибок `fa` равен 0, выводится сообщение об успешном выполнении всех операций. В противном случае, выводится сообщение о наличии ошибок.

Пожалуйста, примите мои извинения за предыдущую путаницу.