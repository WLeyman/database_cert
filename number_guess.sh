#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESS_NUMBER() {
  # ask for a number
  read GUESS

  # check if guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]*$ ]]
  then
    #ask to guess again with an integer
    echo -e "\nThat is not an integer, guess again:"
    GUESS_NUMBER
  else
    # increment amount of guesses
    CURRENT_SCORE=$(($CURRENT_SCORE + 1))
  
    # if guess is greater than secret number
    if [[ $GUESS > $SECRET_NUMBER ]]
    then
      # echo hint
      echo -e "\nIt's lower than that, guess again:\n"
      # guess again
      GUESS_NUMBER
    # if guess is smaller than secret number
    elif [[ $GUESS < $SECRET_NUMBER ]]
    then 
      # echo hint
      echo -e "\nIt's higher than that, guess again:\n"
      # guess again
      GUESS_NUMBER
    else
    #echo correct guess
    echo -e "\nYou guessed it in $CURRENT_SCORE tries. The secret number was $SECRET_NUMBER, Nice job!"
    fi
  fi
}

#ask for username
echo -e "\nEnter your username:"
read USERNAME

# get user id from username
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# if user doesn't exist
if [[ -z $USER_ID ]]
then
  # welcome user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  # create user in database
  CREATE_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  GAMES_PLAYED=0
else
  # if user exists, get user values
  RETURNING_USERNAME_VALUES=$($PSQL "SELECT games_played, best_score FROM users WHERE user_id=$USER_ID;")
  IFS="|" read -r GAMES_PLAYED BEST_SCORE <<< $RETURNING_USERNAME_VALUES

  # welcome back user
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

# generate secret number
SECRET_NUMBER=$(($RANDOM%1000+1))

# set current score to 0
CURRENT_SCORE=0

# start guessing game
echo -e "\nGuess the secret number between 1 and 1000:"
GUESS_NUMBER

# update games played
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED + 1 WHERE username='$USERNAME';")

# check if a best score does not exists
if [[ -z $BEST_SCORE ]]
then
  # update best score
  UPDATE_BEST_SCORE_RESULT=$($PSQL "UPDATE users SET best_score=$CURRENT_SCORE WHERE username='$USERNAME';")
# check if current score better than best score
elif [[ $CURRENT_SCORE < $BEST_SCORE ]]
then
  # update best score
  UPDATE_BEST_SCORE_RESULT=$($PSQL "UPDATE users SET best_score=$CURRENT_SCORE WHERE username='$USERNAME';")
fi
