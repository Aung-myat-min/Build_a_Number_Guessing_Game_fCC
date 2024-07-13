#!/bin/bash

# Define the PSQL command with necessary options
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
RANDOM_NUM=$((1 + $RANDOM % 1000))

RUN(){
  echo -e "Enter your username:"
  read NAME

  # Check if the username exists in the database
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
  if [[ -z $USER_ID ]]
  then
    # If the username doesn't exist, create a new user
    NEW_USER=$($PSQL "INSERT INTO users(name) VALUES('$NAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$NAME'")
    echo -e "\nWelcome, $NAME! It looks like this is your first time here."
  else
    # If the username exists, get the game statistics
    GP=$($PSQL "SELECT games_played FROM users WHERE name = '$NAME'")
    BG=$($PSQL "SELECT best_game FROM users WHERE name = '$NAME'")
    echo -e "\nWelcome back, $NAME! You have played $GP games, and your best game took $BG guesses."
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  TRY=0

  #LOOP UNTIL IT HITS!
  while true
  do
    read NUMBER
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
    else
      TRY=$((TRY + 1))
      if [[ $NUMBER -eq $RANDOM_NUM ]]
      then
        echo -e "\nYou guessed it in $TRY tries. The secret number was $RANDOM_NUM. Nice job!"
        
        # Update user statistics
        UPDATE_DATA=$($PSQL "UPDATE users SET games_played = $GP + 1 WHERE user_id = $USER_ID")
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = $USER_ID")
        if [[ $TRY -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
        then
          UPDATED_DATA=$($PSQL "UPDATE users SET best_game = $TRY WHERE user_id = $USER_ID")
        fi
        break
      elif [[ $NUMBER -gt $RANDOM_NUM ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      elif [[ $NUMBER -lt $RANDOM_NUM ]]
      then
        echo -e "\nIt's higher than that, guess again:"
      fi
    fi
  done
}

RUN
