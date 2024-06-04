#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(($RANDOM % (1000 + 1) + 1))

echo $SECRET_NUMBER

echo Enter your username:
read USER_NAME

USER_INFO=$($PSQL "SELECT * FROM users WHERE username = '$USER_NAME';")

if [[ -z $USER_INFO ]]; then
  echo Welcome, $USER_NAME! It looks like this is your first time here.

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (username) VALUES ('$USER_NAME');")
else
  echo $USER_INFO | while IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME USER_NAME; do
    echo Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
  done
fi

NUMBER_OF_GUESSES=0
echo Guess the secret number between 1 and 1000:

while [[ $INPUT != $SECRET_NUMBER ]]; do
  read INPUT

  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))

  if [[ ! $INPUT =~ ^[0-9]+$ ]]; then
    echo That is not an integer, guess again:
    continue
  fi

  if [[ $INPUT < $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    continue
  fi

  if [[ $INPUT > $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    continue
  fi
done

USER_INFO=$($PSQL "SELECT * FROM users WHERE username = '$USER_NAME';")

echo $USER_INFO | while IFS='|' read -r USER_ID GAMES_PLAYED BEST_GAME USER_NAME; do
  continue
done

UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = $(($GAMES_PLAYED + 1)) WHERE username = '$USER_NAME';")

if [[ $BEST_GAME < $NUMBER_OF_GUESSES ]]; then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USER_NAME';")
fi

echo You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!
