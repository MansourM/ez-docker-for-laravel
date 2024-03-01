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
    # Set variables
    NEW_DB_NAME=$1
    NEW_USER_NAME=$2
    NEW_USER_PASSWORD=$3
    your_mysql_container_name=DB_HOST

    # MySQL root credentials
    MYSQL_ROOT_USER="root"
    MYSQL_ROOT_PASSWORD="your_root_password"

    # Check if the user already exists
    existing_user=$(sudo docker exec -i $DB_HOST mysql -u $MYSQL_ROOT_USER -p $MYSQL_ROOT_PASSWORD -e "SELECT user FROM mysql.user WHERE user='$NEW_USER_NAME';" --skip-column-names -B)

    if [ -n "$existing_user" ]; then
        echo "User '$NEW_USER_NAME' already exists."
    else
        # Create a new database
        sudo docker exec -i $DB_HOST mysql -u $MYSQL_ROOT_USER -p $MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $NEW_DB_NAME;"

        # Create a new user and grant privileges
        sudo docker exec -i $DB_HOST mysql -u $MYSQL_ROOT_USER -p $MYSQL_ROOT_PASSWORD -e "CREATE USER '$NEW_USER_NAME'@'localhost' IDENTIFIED BY '$NEW_USER_PASSWORD';"
        sudo docker exec -i $DB_HOST mysql -u $MYSQL_ROOT_USER -p $MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$NEW_USER_NAME'@'localhost';"
        sudo docker exec -i $DB_HOST mysql -u $MYSQL_ROOT_USER -p $MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;"

        echo "Database '$NEW_DB_NAME' and user '$NEW_USER_NAME' created with full privileges."
    fi
}

# Example usage:
#create_database_user "new_database" "new_user" "password"
