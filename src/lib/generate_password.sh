generate_password() {
    local length=$1
    tr -dc 'A-Za-z0-9!@#$%^&*()_+{}[]:;<>,.?/~`-=' </dev/urandom | head -c $length
}