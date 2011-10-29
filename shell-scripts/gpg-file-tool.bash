#!/bin/bash
#
# a function to be sourced into your shell environment that performs
# various tasks based on the switches it is passed.
#

# if [[ $* -ge 0 ]]
# then
#  echo "WARNING: At least one argument is required. [-h] for Usage information."
#  return 1
# fi

###############################################################################
### Define Variables
###############################################################################
GPG_DEC_OPTIONS="--decrypt --armor"
GPG
GPG_EDIT_OPTIONS
DEF_VIEWER="/usr/bin/nano"
main_function () {

  Usage="Usage: \n \
  \t$0 [-lf:bmcdxh] \n \
  \t\t[-h] \tThis usage text.\n \
  \t\t[-f] \tFile to be encrypted or decrypted. \n \
  \t\t[-l] \tGo to application log directory with ls. \n \
  \t\t[-m] \tModify encrypted file, and re-encrypt.\n \
  \t\t[-d] \tDecrypt encrypted file using default key.\n \
  \t\t[-e] \tEncrypt encrypted file using default key.\n \
  \t\t[-x] \tTurn off debug information.\n"


    if [ "$#" -lt 1 ]
        then
            echo -e $Usage
    fi

OPTIND=1
while getopts lf:bmcdexh ARGS
    do
        case $ARGS in

        l)
            ;;

        f) SRC_FILE=$OPTARG
             if [[ -f "${SRC_FILE}" ]]
                then
                    printf "%s\n" "GOOD: File exists."
                    MIME_TYPE=$(file --no-buffer --mime-type "${SRC_FILE}"| cut -d " " -f2)
                    SRC_DIR=$(dirname "${SRC_FILE}")
                    SRC_FILE=$(basename "${SRC_FILE}")
                    # echo BASE DIR : $SRC_DIR SRC FILE : $SRC_FILE
                else
                    printf "%s\n" "WARN: File does not exist. Cannot continue."
                    return 1
             fi
            ;;

        b)
            ;;

        m) ## Enable modify functionality
        PARAM=EDIT
            ;;

        c)
            ;;

        d) ## Enable decrpyt functionality
        PARAM=DEC
            ;;

        e) ## Enable decrpyt functionality
        PARAM=ENC
            ;;

        x) set +x
            ;;

        h) echo -e $Usage
            ;;

        *) echo -e $Usage
        #return
            ;;
    esac
done

while [[ -z "$SRC_FILE" ]]
    do
        printf "%s\n" "Need at least one file specified. Cannot continue."
        RET_CODE=1
        break
    done

return "${RET_CODE:-0}"
}

main_function $@

[ $? -ne "0" ] && exit 1

## Actions based on options set above

# echo $PARAM; sleep 60


case "${PARAM}" in

    EDIT)
    ## First we need to decrypt input file after making a backup
    echo gpg "${GPG_DEC_OPTIONS}"
    ## Second we need to open file for editing

    ## Third we need to save and re-encrypt file after editing

    ## Fourth we need to
        printf "%s\n" "Take edit action here..."

        ;;

    DEC)
        printf "%s\n" "Take decrypt action on file ${SRC_FILE} here..."

        ## Test if file is pgp and if so, take further action
        if [[ "${MIME_TYPE}" = "application/pgp" ]]; then

            printf "%s\n" "GOOD: ${SRC_FILE} is a GnuPG Encrypted file."

                printf "%s" "Is this a Binary or an Ascii file ([a]Ascii [b]Binary)?"

                read BIN_OR_ASCII
                while [[ -z "${BIN_OR_ASCII}" ]]; do

                    case "${BIN_OR_ASCII}" in

                    [Aa])
                        gpg "${GPG_DEC_OPTIONS}" "${SRC_DIR}/${SRC_FILE}" | "${DEF_VIEWER}"
                        ;;

                    [Bb])
                        gpg "${GPG_DEC_OPTIONS}" "${SRC_DIR}/${SRC_FILE}"
                        ;;

                    *) printf "%s\n" "I am not sure what you are trying to do."
                        unset "${BIN_OR_ASCII}"

                        ;;
                    esac
                done

                    gpg "${GPG_DEC_OPTIONS}" "${SRC_DIR}/${SRC_FILE}" | "${DEF_VIEWER}"
                else
                    RET_CODE=1
                    printf "%s\n" "WARNING: ${SRC_FILE} is not a GnuPG Encrypted file."
                    exit "${RET_CODE}"
        fi
        ;;

    ENC)
        printf "%s\n" "Take encrypt action on file ${SRC_FILE} here..."
        ;;
    *)

        ;;
esac
# gpg --decrypt -r "${DEF_PUBKEY}"
