#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

[[ -z $1 ]] && echo "Please provide an element as an argument." && exit

# LOOKUP FIRST (you missed this!)
if [[ $1 =~ ^[0-9]+$ ]]; then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1;")
else
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1' OR symbol='$1';")
fi

if [[ -z $ATOMIC_NUMBER ]]; then
  echo "I could not find that element in the database."
  exit
fi

# THEN JOIN
ELEMENT_INFO=$($PSQL "SELECT e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number=p.atomic_number JOIN types t ON p.type_id=t.type_id WHERE e.atomic_number=$ATOMIC_NUMBER;")
OLD_IFS=$IFS
IFS='|'

read -ra FIELDS <<< "$ELEMENT_INFO"
IFS=$OLD_IFS

NAME=$(echo "${FIELDS[0]}" | xargs)

SYMBOL=$(echo "${FIELDS[1]}" | xargs)
TYPE=$(echo "${FIELDS[2]}" | xargs)

MASS=$(echo "${FIELDS[3]}" | xargs)

MP=$(echo "${FIELDS[4]}" | xargs)

BP=$(echo "${FIELDS[5]}" | xargs)


echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."