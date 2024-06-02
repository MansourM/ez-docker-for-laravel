generate_password() {
    local length=$1
    local charset="A-Za-z0-9@#%&*"
    tr -dc "$charset" </dev/urandom | head -c $length
}