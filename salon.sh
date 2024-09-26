#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, Plese choose the service you need"

MAIN_MENU() {
   if [[ -n $1 ]]
   then
      echo "$1"
   fi
   

    # Fetch the services from the database
    SERVICES=$($PSQL "SELECT service_id, name FROM services")

    # If no services available 
    if [[ -z $SERVICES ]]
    then
       echo "Shop closed"
    else
       echo "$SERVICES" | while read -r SERVICE_ID BAR NAME
       do
          echo "$SERVICE_ID) $NAME"
       done
    fi

    #read the service required
    read SERVICE_ID_SELECTED

    #select the service ID
    SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SELECTED_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    

    if [[ -z $SELECTED_SERVICE ]]
    then
       MAIN_MENU "requested service not available, please select service id from below list" 
    else
       echo "you have selected $SELECTED_SERVICE"
       echo -e "\nPlease share your contact number\n"
       read CUSTOMER_PHONE

       if [[ !$CUSTOMER_PHONE =~ ^[0-9]+ ]]
       then
          MAIN_MENU "Please enter a valid phone number"
       else
          #check if phone number exists
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          if [[ -z $CUSTOMER_ID ]]
          then
             echo -e "\nI don't have a record for that phone number, what's your name?\n"
             read CUSTOMER_NAME
             echo -e "\nWhat time would you like your cut,$CUSTOMER_NAME?\n"
             read SERVICE_TIME
             INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
             INSERTED_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM CUSTOMERS where phone='$CUSTOMER_PHONE'")
             INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($INSERTED_CUSTOMER_ID,'$SELECTED_SERVICE_ID','$SERVICE_TIME')")
             
             echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"
          else
             CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
             echo -e "\nWelcome Mr.$CUSTOMER_NAME, what time do you like $SELECTED_SERVICE\n"
             read SERVICE_TIME
             echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME.\n"

          fi
       fi
    fi

}

MAIN_MENU
