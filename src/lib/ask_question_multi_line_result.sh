ask_question_multi_line_result() {
    local question=$1
    local delimiter="ez;"
    local result

    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    # Display the question to the user
    echo -e "${GREEN}$question (type '$delimiter' on a new line to finish)${NC}"

    # Prompt the user to paste the content
    echo "Paste your content here. Press Enter after the last line, then type '$delimiter' and press Enter again to finish."

    result=""
    while IFS= read -r line; do
        [[ $line == "$delimiter" ]] && break
        result+="$line"$'\n'
    done

    # Return the result
    echo "$result"
}
