read_multi_line_input() {
    local delimiter=$1
    local result

    result=""
    while IFS= read -r line; do
        [[ $line == "$delimiter" ]] && break
        result+="$line"$'\n'
    done

    echo "$result"
}