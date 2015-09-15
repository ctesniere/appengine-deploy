function messageError() {
    printf "\e[31m ===> %s\e[0m\n" "$1"
}

function messageSuccess() {
    printf "\e[32m ===> %s\e[0m\n" "$1"
}

function appengineDeploy() {

    curl -s https://gist.githubusercontent.com/ctesniere/c34ac1e57f5c44c7fc20/raw/8bf3b40e7c9515c74235b55f1d36e4475a93ca11/mvncolor.sh | bash

    DIRECTORY_EAR=$(find . -d 1 | grep ear)
    CURRENT_DIRECTORY=${PWD##*/}

    if [ ! -f pom.xml ]; then
        messageError "pom.xml file not found"
        return 1

    elif [ "$#" -eq 0 ]; then # TODO ou vide
        messageError "Illegal number of parameters"
        messageError "    arg1 : profil"
        messageError "    arg2 : option of build (optional)"
        return 1

    elif [ ! -z "$(echo "$CURRENT_DIRECTORY" | grep ear)" ]; then
        messageError "Current directory is ear"
        cd .. || return 1
        messageSuccess "cd .."
        
    fi


    if [ "$CURRENT_DIRECTORY" = "vega-is-0km" ]; then
        messageSuccess "Compiling the front"
        cd "./src/main/javascript/" || return 1
        bower install && npm install && grunt
        cd -
    fi

    if [ -d "$DIRECTORY_EAR" ] && [ ! -z "$DIRECTORY_EAR" ]; then
        messageSuccess "Project with a '$DIRECTORY_EAR'"
        mvn-color clean install -P "$1" "$2"

        cd "$DIRECTORY_EAR" || return 1
    fi

    messageSuccess "Appengine update with $1 profil"
    
    # TODO : Ne pas executer ce code si le build precedent fail
    mvn-color clean appengine:update -P "$1" "$2"

    if [ -d "$DIRECTORY_EAR" ] && [ ! -z "$DIRECTORY_EAR" ]; then
        # FIX : Le script ne rentre jamais dans cette condition
        cd .. || return 1
    fi

    Terminal-notifier \
        -contentImage https://cloud.google.com/images/gcp-favicon.ico \
        -sound default \
        -title 'Finished deployment' \
        -subtitle "$1 profile" \
        -group 'appengine-deploy' \
        -message "project : $CURRENT_DIRECTORY"
}
