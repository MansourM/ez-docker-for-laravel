ask_question() {
    local question=$1
    local default=$2
    local result

    # Prompt the user with the question and default answer
    read -p "$question [$default]: " result

    # Use the default if the user presses Enter without typing anything
    if [[ -z "$result" ]]; then
        result=$default
    fi

    echo $result
}