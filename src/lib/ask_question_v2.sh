#TODO This is WIP, read, echo does not work
ask_question_v2() {
    local question=$1
    local default=$2
    local regex=$3
    local required=$4
    local hide_text=$5

    local result

    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local RED='\033[0;31m'
    local NC='\033[0m' # No Color

    while true; do
        # Prompt the user with the question and default answer
        if [ "$hide_text" == "true" ]; then
            read -s -p "$(echo -e "${GREEN}$question ${YELLOW}[$default]${NC}: ")" result
            echo ""  # Move to a new line after hidden input
        else
            read -p "$(echo -e "${GREEN}$question ${YELLOW}[$default]${NC}: ")" result
        fi

        # Use the default if the user presses Enter without typing anything
        if [[ -z "$result" ]]; then
            result=$default
        fi

        # Check if the result is required
        if [ "$required" == "true" ] && [[ -z "$result" ]]; then
            echo -e "${RED}This field is required.${NC}"
            continue
        fi

        # Check if the result matches the regex
        if [ -n "$regex" ] && ! [[ "$result" =~ $regex ]]; then
            echo -e "${RED}Invalid input format, should match regex: '$regex'${NC}"
            continue
        fi

        break
    done

    echo $result
}