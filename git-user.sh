#!/bin/bash

USERS_DB="$HOME/.gitusers"
if [ ! -f "$USERS_DB" ]
then
    touch $USERS_DB
fi

ask_for_update=false
origin=$(git remote -v | grep -e "origin.*(push)" | sed 's/.*@//g' | sed 's/:.*//g')
origin_info=$(grep -i "$origin" "$USERS_DB")

# if no user profile was provided
# try to identify one based on origin url
if [ -z $1 ]
then
    profile_info=$origin_info
else
    profile=$1
    profile_info=$(grep -i "$profile" "$USERS_DB")
    if [ "$origin" != "$profile" ]
    then
        ask_for_update=true
    fi
fi

if [ ! -z "$profile_info" ]
then
    name=$(echo "$profile_info" | cut -d '"' -f2)
    email=$(echo "$profile_info" | cut -d '"' -f3)

    if [ ! -z "$email" ] && [ ! -z "$name" ]
    then
        # TODO
        # git config user.name $name
        # git config user.email $email
        echo $name
        echo $email

        if [ "$ask_for_update" == "true" ] && [ -z $(echo -e "${origin_info}" | tr -d '[[:space:]]') ]
        then
            echo "Save this user for $origin projects (y/n)?"
            read -n 1 action

            case "$action" in
              y | yes )
                yes=true;;
              * )
                ;;
            esac
            if [ "$yes" == "true" ]
            then
                echo "$origin \"$name\" $email" >> $USERS_DB
            fi
            echo ''
        fi
    fi
else
    echo "ERROR: User not found!"
    exit 2
fi
