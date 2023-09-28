#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
  
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  select=$($PSQL "SELECT * FROM services") 
  echo "$select" | while read SERVICE BAR NAME
  do
    echo "$SERVICE) $NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Choose from the list."
  else
    SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_ID_RESULT ]]
    then
      MAIN_MENU "I could not find that service. What would you like for today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")
      SERVICE=$($PSQL "SELECT name from services where service_id=$SERVICE_ID_SELECTED")
      SERVICE=$( echo $SERVICE | sed -E 's/^ *| *$//g')

      if [[ -z $CUSTOMER_ID ]]
      then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) Values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

        if [[ $INSERT_CUSTOMER_RESULT == "INSERT 0 1" ]]
        then
          echo "What time would you like your $SERVICE, $CUSTOMER_NAME?"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id from customers WHERE phone='$CUSTOMER_PHONE'")
          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME') ")
          echo "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        fi
      else
        CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME=$( echo $CUSTOMER_NAME|sed -E 's/^ *| *$//g')
        echo "What time would you like your $SERVICE, $CUSTOMER_NAME?"
        read SERVICE_TIME
        
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) values ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME') ")
        echo  "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
        
      fi
    fi
  fi
}


MAIN_MENU
