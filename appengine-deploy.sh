#!/bin/sh

DIRECTORY_EAR=$(ls | grep ear)
CURRENT_DIRECTORY=${PWD##*/}

curl -sl https://gist.githubusercontent.com/ctesniere/2498a32304e3039152e8/raw/mvncolor.sh -o /tmp/mvncolor.sh
source /tmp/mvncolor.sh

checkDependency() {
    if ! which brew >/dev/null; then
        echo "Install brew ? [Y/N]"
        read PROMPT

        if echo "$PROMPT" | grep -iq "Y"; then
            printf "\e[32m ===> brew is not installed. Installing ...\e[0m\n"
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        fi
    fi

    if which brew >/dev/null; then
        if ! which Terminal-notifier >/dev/null; then
            printf "\e[32m ===> terminal-notifier is not installed. Installing ...\e[0m\n"
            brew install terminal-notifier
        fi
    fi
}

function checkPostTraitement() {
    if [ ! -f pom.xml ]; then
        printError "pom.xml file not found"
        exit
    fi

    if [ "$#" -ne 1 ]; then
        printError "Illegal number of parameters (arg1 : profil)"
        exit
    fi

    if [ ! -z $(echo $CURRENT_DIRECTORY | grep ear) ]; then
        printError "Current directory is ear"
        exit
    fi
}

function buildFront() {
    printf "\e[31m ===> front\e[0m\n"
    CURRENT_DIRECTORY=${PWD##*/}
}

function printSuccess() {
    printf "\e[32m ===> $1 \e[0m\n"
}

function printError() {
    printf "\e[31m ===> $1 \e[0m\n"
}

function notify() {
    if which Terminal-notifier >/dev/null; then
        Terminal-notifier \
            -contentImage https://cloud.google.com/images/gcp-favicon.ico \
            -sound default \
            -title 'Finished deployment' \
            -subtitle "$1 profile" \
            -message "project : $2"
    else
        osascript -e 'tell app "System Events" to display dialog "Pause de 20 secondes"'
    fi
}

checkDependency
checkPostTraitement $@

if [ -d $DIRECTORY_EAR ] && [ ! -z $DIRECTORY_EAR ]; then
    printSuccess "Project with a directory ear ($DIRECTORY_EAR)"
    mvncolor clean install -P $1

    # TODO : Compile front in front module
    cd $DIRECTORY_EAR
fi

printSuccess "Appengine update with $1 profil"

# TODO : Ne pas executer ce code si le build precedent fail
mvncolor clean appengine:update -P $1

if [ -d $DIRECTORY_EAR ] && [ ! -z $DIRECTORY_EAR ]; then
    # TODO : Pb le script ne rentre jamais dans cette condition
    cd ..
fi

notify $1 $CURRENT_DIRECTORY

rm /tmp/mvncolor.sh
