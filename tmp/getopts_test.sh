#!/usr/bin/env bash

name=
age=

echo $* 
while getopts ":a:b:c" opt 
do 
        case $opt in 
                a ) echo $OPTARG 
                    name=$OPTARG
                    echo $OPTIND;; 
                b ) echo "$OPTARG"
                    age=$OPTARG
                    ;;
                c ) echo "c $OPTIND";; 
                ? ) echo "error" 
                    exit 1;; 
        esac 
done 
echo $OPTIND 
shift $(($OPTIND - 1))

echo "#############"
echo "name: $name"
echo "age: $age"
