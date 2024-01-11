#!/bin/bash

# Array of available speakers
speakers=('Claribel Dervla' 'Daisy Studious' 'Gracie Wise' 'Tammie Ema' 'Alison Dietlinde' 'Ana Florence' 'Annmarie Nele' 'Asya Anara' 'Brenda Stern' 'Gitta Nikolina' 'Henriette Usha' 'Sofia Hellen' 'Tammy Grit' 'Tanja Adelina' 'Vjollca Johnnie' 'Andrew Chipper' 'Badr Odhiambo' 'Dionisio Schuyler' 'Royston Min' 'Viktor Eka' 'Abrahan Mack' 'Adde Michal' 'Baldur Sanjin' 'Craig Gutsy' 'Damien Black' 'Gilberto Mathias' 'Ilkin Urbano' 'Kazuhiko Atallah' 'Ludvig Milivoj' 'Suad Qasim' 'Torcull Diarmuid' 'Viktor Menelaos' 'Zacharie Aimilios' 'Nova Hogarth' 'Maja Ruoho' 'Uta Obando' 'Lidiya Szekeres' 'Chandra MacFarland' 'Szofi Granger' 'Camilla Holmström' 'Lilya Stainthorpe' 'Zofija Kendrick' 'Narelle Moon' 'Barbora MacLean' 'Alexandra Hisakawa' 'Alma María' 'Rosemary Okafor' 'Ige Behringer' 'Filip Traverse' 'Damjan Chapman' 'Wulf Carlevaro' 'Aaron Dreschner' 'Kumar Dahl' 'Eugenio Mataracı' 'Ferran Simen' 'Xavier Hayasaka' 'Luis Moray' 'Marcos Rudaski')

# Array of available languages and their abbreviations
languages=('en:english' 'es:spanish' 'fr:french' 'de:german' 'it:italian' 'pt:portuguese' 'pl:polish' 'tr:turkish' 'ru:russian' 'nl:dutch' 'cs:czech' 'ar:arabic' 'zh-cn:chinese' 'hu:hungarian' 'ko:korean' 'ja:japanese' 'hi:hindi')

# Default language
selected_language='en'

# Default speaker
selected_speaker=''

# Default ollama model
selected_ollama_model='james'  # Default model, change if needed

# Function to print items with their index numbers
print_items() {
    local items=("$@")
    echo "Available items with their index numbers:"
    for i in "${!items[@]}"; do
        echo "$i: ${items[$i]}"
    done
}

# Function to map input to items (speakers, languages, or models)
map_item() {
    local input="$1"
    shift
    local items=("$@")

    # Check if the input is a valid index
    if [[ "$input" =~ ^[0-9]+$ && $input -ge 0 && $input -lt ${#items[@]} ]]; then
        local index=$((input))
        echo "${items[$index]}"
        return
    fi

    for item in "${items[@]}"; do
        local abbreviation="${item%%:*}"
        local full_name="${item#*:}"
        if [[ "$input" == "$abbreviation" || "$input" == "$full_name" ]]; then
            echo "$abbreviation"
            return
        fi
    done

    echo "Invalid input."
    exit 1
}

# Function to display help message
display_help() {
    echo "Usage: $0 -p <prompt> [-s <speaker>] [-l <language>] [-m <ollama_model>] [--models] [--speakers] [--languages] [--help]"
    echo "Options:"
    echo "  -p <prompt>         Prompt to be processed."
    echo "  -s <speaker>        Speaker for the text."
    echo "  -l <language>       Language for the text. Use abbreviation or full name."
    echo "  -m <ollama_model>   Ollama model to be used."
    echo "  --models            Display available ollama models."
    echo "  --speakers          Display available speakers."
    echo "  --languages         Display available languages."
    echo "  --help              Display this help message."
    exit 0
}

# Check command-line arguments
while getopts ":p:s:l:m:-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                models)
                    # Display available ollama models
                    ollama list
                    exit 0
                    ;;
                speakers)
                    # Display available speakers
                    print_items "${speakers[@]}"
                    exit 0
                    ;;
                languages)
                    # Display available languages
                    print_items "${languages[@]}"
                    exit 0
                    ;;
                help)
                    # Display help message
                    display_help
                    ;;
                *)
                    echo "Invalid option: --$OPTARG"
                    exit 1
                    ;;
            esac
            ;;
        p)
            # Text argument
            prompt="$OPTARG"
            ;;
        s)
            # Speaker argument
            selected_speaker=$(map_item "$OPTARG" "${speakers[@]}")
            ;;
        l)
            # Language argument
            selected_language=$(map_item "$OPTARG" "${languages[@]}")
            ;;
        m)
            # Ollama model argument
            selected_ollama_model="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

# Check if the -p flag is provided
if [ -z "$prompt" ]; then
    echo "Error: Prompt parameter is required."
    display_help
    exit 1
fi

# Check if the -s flag is provided
if [ -z "$selected_speaker" ]; then
    random_index=$((RANDOM % ${#speakers[@]}))
    selected_speaker="${speakers[$random_index]}"
    echo "No speaker selected. Picking random speaker: $selected_speaker"
else
    echo "Selected speaker: $selected_speaker"
fi

# Check if the -l flag is provided
if [ -n "$selected_language" ]; then
    echo "Selected language: $selected_language"
else
    echo "No language parameter provided. Using the default language: $selected_language"
fi

# Check if the -m flag is provided
if [ -n "$selected_ollama_model" ]; then
    echo "Selected ollama model: $selected_ollama_model"
else
    echo "No ollama model parameter provided. Using the default model: $selected_ollama_model"
fi

tts --text "$(ollama run $selected_ollama_model "$prompt")" --model_name "tts_models/multilingual/multi-dataset/xtts_v2" --out_path "./speak.wav" --speaker_idx "$selected_speaker" --language_idx "$selected_language"
aplay ./speak.wav
#rm speak.wav
