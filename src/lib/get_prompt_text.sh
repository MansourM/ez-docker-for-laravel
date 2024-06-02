get_prompt_text() {
    local question=$1
    local default=$2

    local GREEN='\033[0;32m'
    local YELLOW='\033[0;33m'
    local NO_COLOR='\033[0m'

    echo "${GREEN}$question ${YELLOW}[$default]${NO_COLOR}: "
}