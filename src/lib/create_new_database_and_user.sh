## Add any function here that is needed in more than one parts of your
## application, or that you otherwise wish to extract from the main function
## scripts.
##
## Note that code here should be wrapped inside bash functions, and it is
## recommended to have a separate file for each function.
##
## Subdirectories will also be scanned for *.sh, so you have no reason not
## to organize your code neatly.
##
create_new_database_and_user() {

  if [ "$#" -ne 3 ]; then
      echo -e "\nInvalid Arguments, Usage: $0 <new_db_name> <new_user_name> <new_user_password>\n"
      return 1
  fi

  # Set variables
  NEW_DB_NAME=$1
  NEW_USER_NAME=$2
  NEW_USER_PASSWORD=$3

  echo -e "\n==[ Creating Database: $NEW_DB_NAME with User: $NEW_USER_NAME ]==\n"

  MYSQL_USER="root"
  # DB_ROOT_PASSWORD is read from shared.env

  # Check if database exists (improve error handling)
  if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "SELECT 1 FROM $NEW_DB_NAME;" > /dev/null 2>&1; then
    # Create database
    if ! sudo docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $NEW_DB_NAME;"; then
      echo -e "\n==[ ERROR: Failed to create database '$NEW_DB_NAME'. ]==\n"
      return 1
    fi
    echo -e "\n==[ Created Database: $NEW_DB_NAME ]==\n";
  else
    echo -e "\n==[ Database: $NEW_DB_NAME Already Exists ]==\n";
  fi

  # Check if user exists (improve error handling)
  if ! docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "SELECT user FROM mysql.user WHERE user='$NEW_USER_NAME';" --skip-column-names -B | grep -q "$NEW_USER_NAME"; then
    # Create user and grant privileges
    if ! sudo docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "CREATE USER '$NEW_USER_NAME'@'localhost' IDENTIFIED BY '$NEW_USER_PASSWORD';" || \
       ! sudo docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$NEW_USER_NAME'@'localhost';" || \
       ! sudo docker exec -i $DB_HOST mysql -u$MYSQL_USER -p$DB_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"; then
      echo -e "\n==[ ERROR: Failed to create and grant privileges for user '$NEW_USER_NAME'. ]==\n"
      return 1
    fi
    echo -e "\n==[ User: '$NEW_USER_NAME' created for DB: $NEW_DB_NAME with full privileges ]==\n";
  else
    echo -e "\n==[ User '$NEW_USER_NAME' already exists. ]==\n";
  fi
}
