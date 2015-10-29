#!/bin/bash

USERS_DB="$HOME/.gitusers"
if [ ! -f $USERS_DB ]
then
    touch $USERS_DB
fi

# if no user profile was provided
# try to identify one based on origin url
if [ -z $1 ]
then
    origin=$(git remote -v | grep -e "origin.*(push)" | sed 's/.*@//g' | sed 's/:.*//g')
    profile_info=$(grep -i $origin $USERS_DB)
else
    profile=$1
    profile_info=$(grep -i $profile $USERS_DB)
fi

if [ ! -z profile_info ]
then
    name=$(echo $profile_info | awk '{print $2}')
    email=$(echo $profile_info | awk '{print $3}')

    if [ ! -z $email ] && [ ! -z $name ]
    then
        # git config user.email $email
        echo $name
        echo $email
    fi
else
    echo "Didn't find any user based on origin url or profile provided"
    exit
fi
