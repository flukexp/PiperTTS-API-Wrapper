#!/bin/bash

files=(
    "voice-ca-upc_ona-x-low.tar.gz"
    "voice-ca-upc_pau-x-low.tar.gz"
    "voice-da-nst_talesyntese-medium.tar.gz"
    "voice-de-eva_k-x-low.tar.gz"
    "voice-de-karlsson-low.tar.gz"
    "voice-de-kerstin-low.tar.gz"
    "voice-de-pavoque-low.tar.gz"
    "voice-de-ramona-low.tar.gz"
    "voice-de-thorsten-low.tar.gz"
    "voice-el-gr-rapunzelina-low.tar.gz"
    "voice-en-gb-alan-low.tar.gz"
    "voice-en-gb-southern_english_female-low.tar.gz"
    "voice-en-us-amy-low.tar.gz"
    "voice-en-us-danny-low.tar.gz"
    "voice-en-us-kathleen-low.tar.gz"
    "voice-en-us-lessac-low.tar.gz"
    "voice-en-us-lessac-medium.tar.gz"
    "voice-en-us-libritts-high.tar.gz"
    "voice-en-us-ryan-high.tar.gz"
    "voice-en-us-ryan-low.tar.gz"
    "voice-en-us-ryan-medium.tar.gz"
    "voice-en-us_lessac.tar.gz"
    "voice-es-carlfm-x-low.tar.gz"
    "voice-es-mls_10246-low.tar.gz"
    "voice-es-mls_9972-low.tar.gz"
    "voice-fi-harri-low.tar.gz"
    "voice-fr-gilles-low.tar.gz"
    "voice-fr-mls_1840-low.tar.gz"
    "voice-fr-siwis-low.tar.gz"
    "voice-fr-siwis-medium.tar.gz"
    "voice-is-bui-medium.tar.gz"
    "voice-is-salka-medium.tar.gz"
    "voice-is-steinn-medium.tar.gz"
    "voice-is-ugla-medium.tar.gz"
    "voice-it-riccardo_fasol-x-low.tar.gz"
    "voice-kk-iseke-x-low.tar.gz"
    "voice-kk-issai-high.tar.gz"
    "voice-kk-raya-x-low.tar.gz"
    "voice-ne-google-medium.tar.gz"
    "voice-ne-google-x-low.tar.gz"
    "voice-nl-mls_5809-low.tar.gz"
    "voice-nl-mls_7432-low.tar.gz"
    "voice-nl-nathalie-x-low.tar.gz"
    "voice-nl-rdh-medium.tar.gz"
    "voice-nl-rdh-x-low.tar.gz"
    "voice-no-talesyntese-medium.tar.gz"
    "voice-pl-mls_6892-low.tar.gz"
    "voice-pt-br-edresson-low.tar.gz"
    "voice-ru-irinia-medium.tar.gz"
    "voice-sv-se-nst-medium.tar.gz"
    "voice-uk-lada-x-low.tar.gz"
    "voice-vi-25hours-single-low.tar.gz"
    "voice-vi-vivos-x-low.tar.gz"
    "voice-zh-cn-huayan-x-low.tar.gz"
    "voice-zh_CN-huayan-medium.tar.gz"
)

# GitHub release URL
url="https://github.com/rhasspy/piper/releases/download/v0.0.2"

# Destination folder to extract the files
destination_folder="models"

# Create the destination folder if it doesn't exist
if [ ! -d "$destination_folder" ]; then
    mkdir "$destination_folder"
fi

# Function to check if a file is already installed
is_installed() {
    local file_basename="$1"
    # Check for .onnx and .onnx.json files
    if [ -f "$destination_folder/$file_basename.onnx" ] || [ -f "$destination_folder/$file_basename.onnx.json" ]; then
        return 0  # File is installed
    else
        return 1  # File is not installed
    fi
}

# Function to download and extract files based on language filter
download_and_extract_files() {
    local lang_filter=$1

    for file in "${files[@]}"; do
        # Check if the file matches the language filter
        if [[ "$file" == *"$lang_filter"* ]]; then
            local file_basename="${file#voice-}"
            file_basename="${file_basename%.tar.gz}"

            # Check if the file is already installed
            if is_installed "$file_basename"; then
                echo "$file is already installed."
            else
                # Download the file
                echo "Downloading $file..."
                curl -L -o "$file" "$url/$file"

                # Extract the file to the destination folder
                echo "Extracting $file..."
                tar -xzf "$file" -C "$destination_folder"

                # Clean up the downloaded archive
                rm "$file"
            fi
        fi
    done
}

# Check if a language filter argument is provided
if [[ -n $1 ]]; then
    # Call the download_and_extract_files function with the language filter argument
    download_and_extract_files "$1"
else
    # No language filter argument provided, download voice-en-us-libritts-high
    download_and_extract_files "voice-en-us-libritts-high"
fi
