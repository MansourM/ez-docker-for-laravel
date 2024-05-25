ask_question_multi_line_result() {
    local question=$1
    local delimiter="ez;"
    local result

    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m' # No Color

    # Display the question to the user before starting the loop
    echo -e "${GREEN}$question ${YELLOW}[type '$delimiter' on a new line to finish]${NC}"

    result=""
    while IFS= read -r line; do
        [[ $line == "$delimiter" ]] && break
        result+="$line"$'\n'
    done

    # Return the result
    echo "$result"
}