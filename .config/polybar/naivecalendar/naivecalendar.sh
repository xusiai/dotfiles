#!/bin/bash

param="$(printf ' %q' "$@")"
if [ -z "$@" ]; then
    cmd="${BASH_SOURCE%/*}/naivecalendar.py"
else
    cmd="${BASH_SOURCE%/*}/naivecalendar.py $(printf ' %q' "$@")"
fi

##############################################################################
####################  Process command line arguments #########################
##############################################################################


while [ $# -gt 0 ]; do
    key="$1"
    case $key in
      -h|--help)
        $cmd
        exit 0
        ;;
      -V|--version)
        $cmd
        exit 0
        ;;
      -t|--theme)
        OPT_THEME="$2"
        shift
        shift
        ;;
      -v|--verbose)
        IS_VERBOSE='true'
        shift
        ;;
      -x|--clipboard)
        IS_CLIPBOARD='true'
        shift
        ;;
      -p|--print)
        IS_PRINT='true'
        shift
        ;;
      -f|--format)
        shift
        shift
        ;;
      -e|--editor)
        shift
        shift
        ;;
      -l|--locale)
        shift
        shift
        ;;
      -d|--date)
        shift
        shift
        ;;
      -c|--read-cache)
        shift
        ;;
      *)
        echo "Argument non défini : '$key'" 
        shift
        ;;
    esac
done


# load theme file
THEME_CACHE_FILE="$HOME/.cache/naivecalendar/theme_cache.txt"
THEME_USER_PATH="$HOME/.config/naivecalendar/themes"
THEME_SOURCE_PATH="${BASH_SOURCE%/*}/themes"



# forced with cmd line argument
if ! [ -z "$OPT_THEME" ]; then
    # search in user path before
    THEME="$THEME_USER_PATH/$OPT_THEME.rasi"
    if ! test -f "$THEME"; then
        THEME="$THEME_SOURCE_PATH/$OPT_THEME.rasi"
    fi
    if ! test -f "$THEME"; then
        echo "theme '$OPT_THEME' doesn't exist"
        exit 0
    fi

# otherwise, look in cache
elif test -f "$THEME_CACHE_FILE"; then
    # look in user path, then in source path
    THEME="$THEME_USER_PATH/$(cat $THEME_CACHE_FILE).rasi"
    if ! test -f "$THEME"; then
        THEME="$THEME_SOURCE_PATH/$(cat $THEME_CACHE_FILE).rasi"
    fi
    if ! test -f "$THEME"; then
        echo "*************************************************************************"
        echo "* '$(cat $THEME_CACHE_FILE)' theme doesn't exist anymore, "
        echo "*    - please remove $THEME_CACHE_FILE    "
        echo "* or                                                                    *"
        echo "*    - force a theme with -t|--theme argument,                          *"
        echo "*      then switch again to an existing theme to override cache file    *"
        echo "*************************************************************************"
        exit 0
    fi

else
    THEME="$THEME_SOURCE_PATH/classic_dark_extended.rasi"
fi

##############################################################################
############################  call rofi  #####################################
##############################################################################

ROFI_LOG_FILE="$HOME/.cache/naivecalendar/rofi_log.txt"
mkdir -p "$(dirname $ROFI_LOG_FILE)"
touch $ROFI_LOG_FILE

# Determine if is it a "first" call or a recursion
if [ -z $NAIVECALENDAR_FIRST_CALL ]; then
    export NAIVECALENDAR_FIRST_CALL="true"
fi
if [ -z $NAIVECALENDAR_SECOND_CALL ]; then
    export NAIVECALENDAR_SECOND_CALL="true"
fi

loop_nb=-1

if [[ "$NAIVECALENDAR_FIRST_CALL" == "true" && "$NAIVECALENDAR_SECOND_CALL" == "true" ]]; then
    loop_nb=0
    export NAIVECALENDAR_FIRST_CALL="false"

    # empty log file at first call
    echo "--- end naivecalendar rofi log ---" > "$ROFI_LOG_FILE"

elif [[ "$NAIVECALENDAR_FIRST_CALL" == "false" && "$NAIVECALENDAR_SECOND_CALL" == "true" ]]; then
    loop_nb=1
    export NAIVECALENDAR_FIRST_CALL="false"
    export NAIVECALENDAR_SECOND_CALL="false"


elif [[ "$NAIVECALENDAR_FIRST_CALL" == "false" && "$NAIVECALENDAR_SECOND_CALL" == "false" ]]; then
    loop_nb=2
fi


# launch rofi
rofi_output="$(rofi -show calendar \
    -modi "calendar:$cmd" \
    -theme-str '@theme "'$THEME'"' \
    2>&1)"

# write to log file (prepend because of recursion)
printf '%s\n' "$rofi_output" | tac | while read -r line; do sed -i '1s?^?'"$line"'\n?' "$ROFI_LOG_FILE"; done

if [ $loop_nb -eq 0 ]; then
    sed -i  "1i--- first call ---" "$ROFI_LOG_FILE"
elif [ $loop_nb -eq 1 ]; then
    sed -i "1i--- first recursion ---" "$ROFI_LOG_FILE"
elif [ $loop_nb -eq 2 ]; then
    sed -i "1i--- 2+ recursion ---" "$ROFI_LOG_FILE"
fi


##############################################################################
####################  Naivecalendar ouputs ###################################
##############################################################################

# execute copy-to-clipboard or print action only with main/first script call
if [ "$loop_nb" -eq 0 ]; then

    # print log
    if [ "$IS_VERBOSE" = "true" ]; then
        cat "$ROFI_LOG_FILE"
    fi

    # print date to stdout
    if [ "$IS_CLIPBOARD" = "true" ]; then
        FILE="$HOME/.cache/naivecalendar/pretty_print_cache.txt"
        cat $FILE | xclip -selection clipboard &
    fi

    # print date to stdout
    if [ "$IS_PRINT" = "true" ]; then
        FILE="$HOME/.cache/naivecalendar/pretty_print_cache.txt"
        cat $FILE > "$HOME/temp.txt"
        printf "%s" "$(cat $FILE)"
    fi
fi

