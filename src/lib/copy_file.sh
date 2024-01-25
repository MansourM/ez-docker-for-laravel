## Add any function here that is needed in more than one parts of your
## application, or that you otherwise wish to extract from the main function
## scripts.
##
## Note that code here should be wrapped inside bash functions, and it is
## recommended to have a separate file for each function.
##
## Subdirectories will also be scanned for *.sh, so you have no reason not
## to organize your code neatly.
##
# Define a function for copying files and checking errors
copy_file() {
    local source_file=$1
    local target_dir=$2
    local target_file=$3

    echo "Copying $source_file to $target_dir folder..."
    if [ -f "$source_file" ]; then
        cp "$source_file" "$target_dir/$target_file"
        chmod +x "$target_dir/$target_file"

        # Check if file copying was successful
        if [ $? -ne 0 ]; then
            echo "Error: Failed to copy $source_file."
            exit 1
        fi
    else
        echo "Error: $source_file not found."
        exit 1
    fi
}
