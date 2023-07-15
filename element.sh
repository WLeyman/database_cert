#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ ! $1 ]]
then
  echo Please provide an element as an argument.
else
  # check if input is a number
  if [[ $1 =~ ^[0-9]*$ ]]
  then
    # get atomic number from numeric input.
    # this is done to check if the value is in the database
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1;")

  else
    # get atomic number from string input
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE (name='$1') OR (symbol='$1');")

  fi

  # if atomic number is not found, return error
  if [[ -z $ATOMIC_NUMBER ]]
  then
    # echo invalid input response
    echo -e "I could not find that element in the database."

  else
    # get element info
    ELEMENT_INFO=$($PSQL "SELECT * FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
    
    #read info into variables
    IFS="|" read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING BOILING TYPE <<< "$ELEMENT_INFO"
    
    # echo info
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."

  fi
fi