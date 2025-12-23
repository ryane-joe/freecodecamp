#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"
echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

if [[ -z $USER_ID ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses."
fi


SECRET=$(( RANDOM % 1000 + 1 ))
GUESSES=0
echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    
    continue
  fi
  
  ((GUESSES++))
  
  if [[ $GUESS -eq $SECRET ]]; then
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET. Nice job!"
    INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESSES);")
    break
  elif [[ $GUESS -gt $SECRET ]]; then
    echo "It's lower than that, guess again:"
  else

    echo "It's higher than that, guess again:"
  fi
done
