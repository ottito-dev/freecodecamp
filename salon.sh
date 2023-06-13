#!/bin/bash
# PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
PSQL="psql --username=freecodecamp --dbname=salon -t -c"
echo -e "\n~~~~ NICE SALON ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 
  echo -e "\n1) cut\n2) color\n3) perm"
  read SERVICE_ID_SELECTED

  SERVICE_IN_DB=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_IN_DB ]]
  then
    MAIN_MENU
  else
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE

    PHONE_IN_DB=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $PHONE_IN_DB ]]
    then
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME

      echo -e "\nPlease enter the service time:"
      read SERVICE_TIME

      REGISTER_CUSTOMER $CUSTOMER_PHONE $CUSTOMER_NAME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      REGISTER_APPOINTMENT $CUSTOMER_ID $SERVICE_ID_SELECTED $SERVICE_TIME
    fi
  fi
}

REGISTER_CUSTOMER() {
  REGISTER_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$1', '$2')")
}

REGISTER_APPOINTMENT() {
  REGISTER_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($1, $2, '$3')")

  APPOINTMENT_INFO=$($PSQL "SELECT services.name, time, customers.name FROM services INNER JOIN appointments USING(service_id) INNER JOIN customers USING(customer_id) WHERE customer_id = $1")

  echo "$APPOINTMENT_INFO" | sed 's/ |//g' | while read SERVICE TIME NAME
  do
    echo -e "\nI have put you down for a $SERVICE at $TIME, $NAME."
  done
}

MAIN_MENU
