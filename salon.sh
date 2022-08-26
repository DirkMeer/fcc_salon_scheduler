#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Reservation ~~~~~\n"

MAIN_MENU() {
  #declare variables
  AVAILABLE_SERVICES="$($PSQL "SELECT service_id, name FROM services")"
  #whenever you need the list of services

  #test for arguments and print them out if present
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #start the service reservation
  echo "What type of service would you like?"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME

  do #start a while loop on $available services
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then #If input is anything but numbers
    MAIN_MENU "Please enter a valid service number."
  else #request id from db to see if it exists
    SERVICE_ID_SELECTED_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_ID_SELECTED_RESULT ]]
    then
      MAIN_MENU "Please enter a valid service number."
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      #see if this customer exists by trying to get the name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then #If there is no preexisting customer, get more info
        # get new customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        #insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #Ask for time
      echo -e "\nAt what time would you like to come by?"
      read SERVICE_TIME

      #Make reservation
      MAKE_RESERVATION_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      #Get service name store in variable
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      #Get customer name store in variable
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
      #Confirmation message
      echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
    fi
  fi
}



MAIN_MENU #Actually call the main menu so it appears