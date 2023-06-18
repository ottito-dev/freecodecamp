#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GENERATE_SECRET_NUMBER() {
  SECRET_NUMBER=$((1 + $RANDOM % 1000))
}

PLAY_GAME() {
  ATTEMPTS=0

  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  ATTEMPTS=$(( $ATTEMPTS + 1 ))
  
  while [ $GUESS != $SECRET_NUMBER ]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    else
      ATTEMPTS=$(( $ATTEMPTS + 1 ))

      if [[ $GUESS > $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi

      read GUESS
    fi
  done

  INSERT_GAME_INFO_RESULT=$($PSQL "INSERT INTO games (player_id, attempts) VALUES ($1, $ATTEMPTS)")

  if [[ $INSERT_GAME_INFO_RESULT == "INSERT 0 1" ]]
  then
    echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}

echo "Enter your username:"
read USER_NAME

PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USER_NAME'")

if [[ -z $PLAYER_ID ]]
then
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players (username) VALUES ('$USER_NAME')")

  if [[ $INSERT_PLAYER_RESULT == "INSERT 0 1" ]]
  then
    PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USER_NAME'")
    
    echo "Welcome, $USER_NAME! It looks like this is your first time here."
  fi
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE player_id = $PLAYER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(attempts) FROM games WHERE player_id = $PLAYER_ID")

  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GENERATE_SECRET_NUMBER

PLAY_GAME $PLAYER_ID