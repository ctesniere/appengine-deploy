#!/usr/bin/env bash

curl -s https://gist.githubusercontent.com/ctesniere/c34ac1e57f5c44c7fc20/raw/8bf3b40e7c9515c74235b55f1d36e4475a93ca11/mvncolor.sh | bash

DIRECTORY_EAR=$(ls | grep ear)

if [ ! -f pom.xml ]; then
	printf "\e[31m ===> pom.xml file not found\e[0m\n"
	exit 1
fi
if [ "$#" -ne 1 ]; then
	printf "\e[31m ===> Illegal number of parameters (arg1 : profil)\e[0m\n"
	exit 1
fi
if [ ! -z $(echo ${PWD##*/} | grep ear) ]; then
	printf "\e[31m ===> Current directory is ear\e[0m\n"
	exit 1
fi

if [ -d $DIRECTORY_EAR ] && [ ! -z $DIRECTORY_EAR ]; then
	printf "\e[32m ===> Project with a '$DIRECTORY_EAR'\e[0m\n"
	printf "\e[32m ===> $(pwd)\e[0m\n"
	mvn-color clean install -P $1

	cd $DIRECTORY_EAR
fi

printf "\e[32m ===> Appengine update with $1 profil\e[0m\n"
printf "\e[32m ===> $(pwd)\e[0m\n"
mvn-color clean appengine:update -P $1

if [ -d $DIRECTORY_EAR ] && [ ! -z $DIRECTORY_EAR ]; then
	cd ..
fi

Terminal-notifier -message "Finished deployment"
