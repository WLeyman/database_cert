#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\n~~~~ Available services ~~~~"
  fi
  
  # Show service selection
  SERVICES_OUTPUT=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES_OUTPUT" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Poll service
  echo -e "\nWhich service would you like to book?"
  read SERVICE_ID_SELECTED
  
  # get service name from ID
  REQUESTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  
  # check if valid service requested
  if [[ -z $REQUESTED_SERVICE_NAME ]]
  then
    # Send back to services menu
    SERVICES_MENU "Please pick one of the offered services."
  else
    APPOINTMENT_MAKER
  fi
}

APPOINTMENT_MAKER() {
  # Poll phone number
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE
  
  # Get customer name from database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  
  # Check if phone in database
  if [[ -z $CUSTOMER_NAME ]]
  then
    # Ask for name
    echo -e "\nPlease provide a name for your new profile."
    read CUSTOMER_NAME

    # Add new customer to database
    NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
  fi

  # ask for appointment time
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME

  # Get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  # add appointment to database
  APPOINTMENT_CREATION_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');") 

  # Get service Name
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  # happy appointment message
  echo -e "\nI have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
}

SERVICES_MENU