ask_question() {
    local question=$1
    local default=$2
    local result

    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m' # No Color

    # Prompt the user with the question and default answer
    echo -e -n "${GREEN}$question ${YELLOW}[$default]${NC}: "

    # Use the default if the user presses Enter without typing anything
    if [[ -z "$result" ]]; then
        result=$default
    fi

    echo $result
}