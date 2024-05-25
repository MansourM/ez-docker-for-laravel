ask_question_multi_line_result() {
    local question=$1
    local delimiter="ez;"
    local result

    # Colors
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    # Prompt the user to enter the content
    echo -e "${GREEN}$question (type '$delimiter' on a new line to finish)${NC}"
    result=""
    while IFS= read -r line; do
        [[ $line == "$delimiter" ]] && break
        result+="$line"$'\n'
    done

    echo "$result"
}