#!/bin/bash
set -e
export ENCODING="$(locale charmap)"
export DEBIAN_FRONTEND="noninteractive"

if [ $ENCODING != "UTF-8" ]; then
	echo "Installing UTF-8 encoding..."
	export LANGUAGE=RU &&
	export LANG=ru_RU.UTF-8 &&
	export LC_IDENTIFICATION="ru_RU.UTF-8" &&
	export LC_ALL="ru_RU.UTF-8" &&
	apt update -qq && apt install -y -qq locales language-pack-ru nano && locale-gen ru_RU ru_RU.UTF-8
fi

echo "Приветствую в моём великолепном скрипте настройки VPS"
echo "Идёт подготовка. Сейчас будет установлено необходимое ПО для настройки сервера, если его ещё нет."
sleep 5;
apt update -qq && apt upgrade -y && apt install -y -qq nano software-properties-common python-software-properties curl wget
add-apt-repository ppa:certbot/certbot -y &> /dev/null
add-apt-repository ppa:ondrej/php -y &> /dev/null
apt -qq update
echo "Теперь можно продолжить"
echo "Вам необходимо будет ответить на несколько вопросов, прежде чем произойдёт установка всего необходимого ПО"

echo ""

echo "Для начала вам необходимо выбрать основу вашего веб сервера"
echo "У вас есть вариант LEMP (Nginx, MySQL, PHP-Fpm) - быстрый, надёжный, можно несколько версий PHP держать. Но не так прост в управлении и нет поддержки .htaccess"
echo "Также можно использовать LAMP: (Apache2 MySQL PHP) - не такой быстрый, но более гибкий сервер. Легко поддаётся расширению с помощью .htaccess файла"

echo ""

# Уточняю.
PS3="Ваш выбор: "

select stack in "LEMP" "LAMP"
do
  echo
  echo "Вы выбрали $stack!"
  echo
  break
done

if [ $stack = "LEMP" ]; then
	echo SERV=nginx >> /etc/environment
	export SERV=nginx
else
	export SERV=apache2
  	echo SERV=apache2 >> /etc/environment
fi

echo "Великолепно! Давайте теперь выберем версию php."
echo "Я бы рекомендовал использовать последнюю версию 7.2"
echo "Однако некоторые CMS требуют более старую версию."

echo ""

select  phpver in "7.2" "7.1" "7.0" "5.6"
do
  echo ""
  if [ $stack = "LEMP" ]; then
  	echo "Вы выбрали версию php$phpver-fpm"
  else
	echo "Вы выбрали версию php-$phpver"
  fi
  echo ""
  break
done

echo "Давайте теперь определимся с базой данных"
echo "У нас есть следующие варианты:"
echo "Percona-server - хорошо подходит для больших объёмов данных"
echo "MySQL server - старая добрая классика :)"
echo "MariaDB - логическое продолжение MySQL"

echo ""

select db in "Percona" "MySQL" "MariaDB"
do
  echo ""
  echo "Вы выбрали $db"
  echo ""
  break
done

echo "Будем ли настраивать FTP доступ?"

echo ""

select installFtp in "Да" "Нет"
do
  echo ""
  if [ $installFtp = "Да" ]; then
  	echo "Значит будем настраивать FTP"
  else
	echo "Пропустим установку и настройку FTP сервера"
  fi
  echo ""
  break
done 
