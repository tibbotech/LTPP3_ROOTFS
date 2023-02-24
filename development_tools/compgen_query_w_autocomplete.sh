#!/bin/bash -m

#---INPUT ARGS
containerID__input="${1}"
query__input="${2}"
table_numOfRows__input="${3}"
table_numOfCols__input="${4}"
table_leadingSpace__input="${5}"
output_fPath__input="${6}"
tibboHeader_prepend_numOfLines__input=${7}



#---FUNCTIONS
function append_slash__func() {
    #Input args
    local cntnrID__input=${1}   #container-ID
    local string__input=${2}

    #Define variable
    local ret=${string__input}
    local trailingSlash_isFound=false

    #Append backslash (if 'string__input' is a directory) 
    local dirExists=`checkIf_dir_exists__func "${cntnrID__input}" "${string__input}"`
    if [[ ${dirExists} == true ]]; then
        #Check if 'string__input' already contains a trailing slash (/)
        trailingSlash_isFound=`checkIf_string_contains_a_trailing_specified_chars__func \
                "${string__input}" \
                "${DOCKER__NUMOFCHARS_1}" \
                "${DOCKER__SLASH}"`
        if [[ ${trailingSlash_isFound} == false ]]; then    #contains no trailing slas (/)
            ret="${string__input}${DOCKER__SLASH}"  #append slash (/)
        fi
    fi

    #Output
    echo "${ret}"
}

function add_leading_spaces__func() {
    #Input args
    local strResult__input=${1}
    local leadingSpaces__input=${2}

    #1. Add LEADING spaces
    local ret=${leadingSpaces__input}${strResult__input}

    #3. Output
    echo "${ret}"
}

function checkForMatch_keyWord_within_string__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local string__input=${1}
    local keyWord__input=${2}
    local matchType__input=${3}
    shift
    shift
    shift
    local dataArr__input=("$@")

    #Find match
    local numOfMatches=`get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func "${string__input}" \
                        "${keyWord__input}" \
                        "${matchType__input}" \
                        "${dataArr__input[@]}"`
    #Output
    if [[ ${numOfMatches} -gt ${DOCKER__NUMOFMATCH_0} ]]; then  #no match
        echo "true"
    else    #match
        echo "false"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local string__input=${1}
    local keyWord__input=${2}
    local matchType__input=${3}
    shift
    shift
    shift
    local dataArr__input=("$@")

    #Convert backslash (\) to (;)
    #Remarks:
    #   The reason for this is because 'grep' has shown issues when using backslash(es) (\)
    local keyWord_conv=`echo "${keyWord__input}" | sed 's/\\\/;/g'`

    local string_conv=${DOCKER__EMPTYSTRING}
    if [[ ! -z "${string__input}" ]]; then
        string_conv=`echo "${string__input}" | sed 's/\\\/;/g'`
    fi

    #Find match
    local dataArrItem=${DOCKER__EMPTYSTRING}
    local dataArrItem_conv=${DOCKER__EMPTYSTRING}
    local count=0
    local ret=0

    case "${matchType__input}" in
        ${COMPGEN__CHECKFORMATCH_ANY})
            if [[ "${string__input}" != "${DOCKER__EMPTYSTRING}" ]]; then
                ret=`echo "${string_conv}" | grep -oE "${keyWord_conv}" | wc -l`
            else
                for dataArrItem in "${dataArr__input[@]}"
                do
                    #Convert string to human readable text
                    dataArrItem_conv=`echo "${dataArrItem}" | sed 's/\\\/;/g'`

                    #Check if there is match
                    count=`echo "${dataArrItem_conv}" | grep -oE "${keyWord_conv}" | wc -l`
                    if [[ ${count} -gt ${DOCKER__NUMOFMATCH_0} ]]; then #match was found
                         #increment 'ret'
                        (( ret++ ))
                    fi
                done 
            fi
            ;;
        ${COMPGEN__CHECKFORMATCH_STARTWITH})
            if [[ "${string__input}" != "${DOCKER__EMPTYSTRING}" ]]; then
                ret=`echo "${string_conv}" | grep -oE "^${keyWord_conv}" | wc -l`
            else
                for dataArrItem in "${dataArr__input[@]}"
                do
                    #Convert string to human readable text
                    dataArrItem_conv=`echo "${dataArrItem}" | sed 's/\\\/;/g'`

                    #Check if there is match
                    count=`echo "${dataArrItem_conv}" | grep -oE "^${keyWord_conv}" | wc -l`

                    if [[ ${count} -gt ${DOCKER__NUMOFMATCH_0} ]]; then #match was found
                         #increment 'ret'
                        (( ret++ ))
                    fi
                done 
            fi
            ;;
        ${COMPGEN__CHECKFORMATCH_ENDWITH})
            if [[ "${string__input}" != "${DOCKER__EMPTYSTRING}" ]]; then
                ret=`echo "${string_conv}" | grep -oE "${keyWord_conv}$" | wc -l`
            else
                for dataArrItem in "${dataArr__input[@]}"
                do
                    #Convert string to human readable text
                    dataArrItem_conv=`echo "${dataArrItem}" | sed 's/\\\/;/g'`

                    #Check if there is match
                    count=`echo "${dataArrItem_conv}" | grep -oE "${keyWord_conv}$" | wc -l`
                    if [[ ${count} -gt ${DOCKER__NUMOFMATCH_0} ]]; then #match was found
                         #increment 'ret'
                        (( ret++ ))
                    fi
                done
            fi
            ;;
        ${COMPGEN__CHECKFORMATCH_EXACT})
            if [[ "${string__input}" != "${DOCKER__EMPTYSTRING}" ]]; then
                ret=`echo "${string_conv}" | grep -oE "(^|[[:blank:]])${keyWord_conv}($|[[:blank:]])" | wc -l`
            else
                for dataArrItem in "${dataArr__input[@]}"
                do
                    #Convert string to human readable text
                    dataArrItem_conv=`echo "${dataArrItem}" | sed 's/\\\/;/g'`

                    #Check if there is match
                    count=`echo "${dataArrItem_conv}" | grep -oE "(^|[[:blank:]])${keyWord_conv}($|[[:blank:]])" | wc -l`
                    if [[ ${count} -gt ${DOCKER__NUMOFMATCH_0} ]]; then #match was found
                         #increment 'ret'
                        (( ret++ ))
                    fi
                done
            fi
            ;;
    esac

    #Output
    echo "${ret}"

    #Turn-on Expansion
    enable_expansion__func
}

function remove_trailingSlash__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local ret=${DOCKER__EMPTYSTRING}
    local string_len=0
    local string_wo_trailingChar_len=0

    #Check if trailing slash is present
    local trailingSlash_isPresent=`checkForMatch_keyWord_within_string__func "${string__input}" \
                        "${DOCKER__SLASH}" \
                        "${COMPGEN__CHECKFORMATCH_ENDWITH}" \
                        "${DOCKER__EMPTYSTRING}"`
    if [[ ${trailingSlash_isPresent} == false ]]; then  #trailing backslash not found
        ret=${string__input}
    else    #trailing backslash found
        string_len=${#string__input}   #get length
        string_wo_trailingChar_len=$((string_len - 1))  #get length without trailing slash

        ret=${string__input:0:string_wo_trailingChar_len}  #get string without trailing slash
    fi

    #Output
    echo "${ret}"
}

function subst_a_combo_of_dot_slash_backslash_to_correct_format__func() {
    #Input args
    local string__input="${1}"

    #Define array containing matching elements
    local matchPatternArr=()
    matchPatternArr=("${DOCKER__DOT}")
    matchPatternArr+=("${DOCKER__DOTDOT}")
    matchPatternArr+=("${DOCKER__SPACEDOT}")

    #IMPORTANT:
    #   Do NOT forget to'double-quote' variables. 
    case "${string__input}" in
        "${DOCKER__ESCAPED_BACKSLASH}")    #equivalent to backslash (\)
            #Remarks:
            #   When comparing, a backslash (\) has to be written as (\\),...
            #   ...because each double-backslash represents an escaped backslash.
            #   During the comparison the each escaped backslash (\\) becomes a backslash (\).
            ret="${DOCKER__QUADRUPLE_ESCAPED_BACKSLASH}"
            ;;
        "${DOCKER__DOUBLE_ESCAPED_BACKSLASH}") #equivalent to double backslash (\\)
            #Remarks:
            #   When comparing, a double backslash (\\) has to be written as (\\\\),...
            #   ...because each double-backslash represents an escaped backslash.
            #   During the comparison the each escaped backslash (\\) becomes a backslash (\).
            ret="${DOCKER__QUADRUPLE_ESCAPED_BACKSLASH}"
            ;;
        "${DOCKER__TRIPLE_ESCAPED_BACKSLASH}") #equivalent to double backslash (\\\)
            #Remarks:
            #   When comparing, a triple backslash (\\\) has to be written as (\\\\\\),...
            #   ...because each double-backslash represents an escaped backslash.
            #   During the comparison the each escaped backslash (\\) becomes a backslash (\).
            ret="${DOCKER__QUADRUPLE_ESCAPED_BACKSLASH}"
            ;;
        *)
            #Start substition sequence
            #***WARNING: The sequence has to happen this way. Do NOT change the sequence.
            #Remarks:
            #   In case NO variables are used in 'sed', use a single-quote instead of...
            #   ...a double-quote to mark the start and end of a sed-statement.
            #   For example:
            #       Use sed 's/\\\\\./\\./g' instead of sed "s/\\\\\./\\./g"
            #Reason:
            #   This would reduce the number of backslashes, which are needed to...
            #   ...escape the special chars by half.

            #1. .\ becomes .
            #Remarks: 
            #   1. No asterisk (*) is used here because each (.\) needs to be converted to (.)
            #   2. Only substitute if 'string__input' contains only backslash-dot-slash (\./)
            local subst1="${string__input}"
            if [[ ${string__input} =~ ${DOCKER__REGEX_BACKSLASH_DOT_SLASH_EXACTMATCH} ]]; then
                subst1=`echo "${string__input}" | sed 's/\\.\\\/\\./g'`
            fi

            #2. \. becomes .
            #Remarks: 
            #   1. No asterisk (*) is used here because each (\.) needs to be converted to (.)
            #   2. Only substitute if 'string__input' contains only backslash-dot-slash (\./)
            local subst2="${subst1}"
            if [[ ${string__input} =~ ${DOCKER__REGEX_BACKSLASH_DOT_SLASH_EXACTMATCH} ]]; then
                subst2=`echo "${subst1}" | sed 's/\\\\\./\\./g'`
            fi

            #3. ending with . becomes ./
            #Remark:
            #   Only append a slash (/) if:
            #   1. 'subst2' consists of 1 char and it's a dot (.)
            #   2. 'subst2' consists of multiple chars and the last 2 chars is a dot-dot (..)
            local subst3=${subst2}  #initial value

            #3.1. get the LAST char of 'subst2'
            local lastChar=`get_last_nChars_ofString__func "${subst2}" "${DOCKER__NUMOFCHARS_1}"`
            #Proceed if 'lastChar' is a dot (.)
            if [[ "${lastChar}" == "${DOCKER__DOT}" ]]; then
                #3.2. get the LAST 2 chars of 'subst2'
                #Remarks:
                #   1. if 'lastTwoChars = Empty String', then 'subst2' consists of 1 char only.
                #   ...OR...
                #   2. if 'lastTwoChars is a dot-dot (..), then proceed.
                local lastTwoChars=`get_last_nChars_ofString__func "${subst2}" "${DOCKER__NUMOFCHARS_2}"`

                #Get the number of matches
                local numOfMatches=`get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func "${DOCKER__EMPTYSTRING}" \
                        "${lastTwoChars}" \
                        "${COMPGEN__CHECKFORMATCH_STARTWITH}" \
                        "${matchPatternArr[@]}"`

                if [[ ${numOfMatches} -gt ${DOCKER__NUMOFMATCH_0} ]] || \
                        [[ "${lastTwoChars}" == "${DOCKER__EMPTYSTRING}" ]]; then
                    subst3=`echo "${subst2}" | sed 's/\\.$/\\.\\//g'`
                fi
            fi

            #4. \/ becomes /
            #Remark: 
            #   No asterisk (*) is used here because each (\/) needs to be converted to (/)
            local subst4=`echo "${subst3}" | sed 's/\\\\\//\\//g'`

            #5. // becomes /
            #Remark: 
            #   Asterisk (*) is used here because all multiple (//) needs to be converted to (/)
            local subst5=`echo "${subst4}" | sed 's/\\/\\/*/\\//g'`

            #6. \ (sed-representation: \\\) replaced by \\ (sed-representation: \\\\\\)
            #Remark:
            #   When looking carefully, an additional of backslash is added (\).
            #   This is done to escape any (special) character which follows after the backslash(es).
            #   This is the reason why 7 backslashes (\\\\\\ \) (instead of...
            #   ...6 backslashes (\\\\\\) are used to replace the 3 backslashes (\\\).
            local subst6=`echo "${subst5}" | sed 's/\\\/\\\\\\\/g'`

            # #Set output variable
            local ret="${subst6}"
            ;;
    esac

    #Output
    echo "${ret}"
}

function retrieve_leadingStr__compgen_in__and__cmd____func() {
    #---------------------------------------------------------------------"
    # REMARK:
    #   This function outputs 2 values:
    #   1.  str_leading
    #   2.  str_lastWord: string which will be autocompleted
    #   3.  numOfWords
    #   4.  cmd
    #   The values are separated by a SED__GS (\x1D)
    #---------------------------------------------------------------------"
    #Input Args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #1. convert backslash-space (\ ), backslash-t (\t), backslash (\), and space ( ) to human readable text.
    #Remark:
    #   human readable strings are (see file: docker__global.sh)
    #       SED_SUBST_BACKSLASHSPACE="${SED__STX}backslashspace${SED__ETX}"
    #       SED_SUBST_BACKSLASH="${SED__STX}backslash${SED__ETX}"
    #       SED_SUBST_SPACE="${SED__STX}space${SED__ETX}"
    #       SED_SUBST_BACKSLASHT="${SED__STX}backslasht${SED__ETX}" 
    local str_conv=`conv_string_to_human_readable__sub "${string__input}" \
                        "${convSpace__input}"`

    #Get the number of words within 'str_conv'
    local numOfWords=`echo "${str_conv}" | wc -w`

    #2. Get last word and leading string
    #Steps:
    #   1. rev: reverse string
    #   2. sed -e "s/ /% %/": replace all spaces with <space><SED__RS><space> (\x1E \x1E)
    #   3. cut -d"%" -f1: get results which is on the LEFT side of <SED__RS>
    #   4. #1. rev: reverse string back
    #   5. sed -e "s/%//": remove all <SED__RS>
    #2.1 Get last string
    local str_conv_lastWord=`echo "${str_conv}" | rev | sed -e "s/ /% %/" | cut -d"%" -f1 | rev | sed -e "s/%//"`

    #2.2 Get leading string
    local str_conv_leading=`echo "${str_conv}" | rev | sed -e "s/ /% %/" | cut -d"%" -f2- | rev | sed -e "s/%//"`

    #3. Remove the earlier prepended backslash
    local str_lastWord=`inv_human_readable_backTo_string__sub "${str_conv_lastWord}" \
                        "${convSpace__input}"`
    local str_leading=`inv_human_readable_backTo_string__sub "${str_conv_leading}" \
                        "${convSpace__input}"`

    #4.  Check if string__input is 1 word?
    if [[ ${numOfWords} -eq ${DOCKER__NUMOFMATCH_1} ]]; then    #true
        #Check if 'str_lastWord = str_leading'?
        if [[ "${str_lastWord}" == "${str_leading}" ]]; then    #true
            str_leading=${DOCKER__EMPTYSTRING}
        fi
    fi

    #Get length of 'str_lastWord'
    local str_lastWord_len=${#str_lastWord}

    #Check if the retrieved 'str_lastWord' is an Empty String.
    #Remarks:
    #   'str_lastWord' is an Empty String, then:
    #       1. str_leading is an Empty String or contains spaces only
    #       2. str_leading is a non-space string
    #   'str_lastWord' is NOT an Empty String, then:
    #       1. 'string__input' consists of 1 word.
    #       2. 'string__input' consists of multiple words.
    case "${str_lastWord}" in
        ${DOCKER__EMPTYSTRING}) #is an Empty string
            #Set 'str_lastWord' to an Empty String.
            str_lastWord=${DOCKER__EMPTYSTRING}

            #Check if 'str_conv_leading' contains any characters which are NOT a SPACE.
            #Remarks:
            #   1. This function also checks whether 'str_conv_leading' is an Empty String.
            #   2. 'str_conv_leading' is used here on purpose, because special characters like (\),
            #       which contains a SPACE, are ignored when doing this check.
            local leadingStr_contains_nonSpaceChars=`checkIf_string_contains_nonSpace_chars__func "${str_conv_leading}"`
            if [[ ${leadingStr_contains_nonSpaceChars} == true ]]; then    #contains non-space characters as well
                cmd=${COMPGEN__COMPGEN_F}
            else    #contains only spaces
                cmd=${COMPGEN__COMPGEN_C_F}
            fi
            ;;
        *)    #not an Empty String
            cmd=${COMPGEN__COMPGEN_C_F}
            ;;
    esac


    #5. Prep output
    ret="${str_leading}${SED__GS}${str_lastWord}${SED__GS}${numOfWords}${SED__GS}${cmd}"

    #Output
    echo "${ret}"
}
function conv_string_to_human_readable__sub() {
    #Input Args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. (\\\\\\ ) to \x02backslashspace\x03
    local str_subst_backSlashSpace=`echo "${string__input}" | \
                        sed "s/${DOCKER__TRIPLE_ESCAPED_BACKSLASH}${DOCKER__ONESPACE}/${SED_SUBST_BACKSLASHSPACE}/g"`

    # #2. (\\\\t) to \x02slasht\x03 (***NOT-IN-USE***)
    # local str_subst_backslashT=`echo "${str_subst_backSlashSpace}" | \
    #                     sed "s/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}${DOCKER__ESCAPED_T}/${SED_SUBST_BACKSLASHT}/g"`

    #2. Update 'str_subst_backslashT'
    str_subst_backslashT="${str_subst_backSlashSpace}"

    #3. (\\\\) to \x02backslash\x03
    local str_subst_backslash=`echo "${str_subst_backslashT}" | \
                        sed "s/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}/${SED_SUBST_BACKSLASH}/g"`

    #4. ( ) to \x02space\x03
    local ret=${DOCKER__EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backslash}" | sed "s/${DOCKER__ONESPACE}/${SED_SUBST_SPACE}/g"`
    else
        ret=${str_subst_backslash}
    fi
 
    #output
    echo "${ret}"
}
function inv_human_readable_backTo_string__sub() {
    #Input args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. \x02backslash\x03 to (\\\\)
    local str_subst_backslash_inv=`echo "${string__input}" | \
                        sed "s/${SED_SUBST_BACKSLASH}/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}/g"`


    # #2.  \x02slasht\x03 to (\\\\t) (***NOT-IN-USE***)
    # local str_subst_backslashT_inv=`echo "${str_subst_backslash_inv}" | \
    #                     sed "s/${SED_SUBST_BACKSLASHT}/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}${DOCKER__ESCAPED_T}/g"`


    str_subst_backslashT_inv="${str_subst_backslash_inv}"


    #3. \x02backslashspace\x03 to (\ )
    local str_subst_backSlashSpace_inv=`echo "${str_subst_backslashT_inv}" | \
                        sed "s/${SED_SUBST_BACKSLASHSPACE}/${DOCKER__TRIPLE_ESCAPED_BACKSLASH}${DOCKER__ONESPACE}/g"`

    #4. \x02space\x03 to ( )
    local ret=${DOCKER__EMPTYSTRING}
    if [[ "${convSpace__input}" == true ]]; then
        ret=`echo "${str_subst_backSlashSpace_inv}" | sed "s/${SED_SUBST_SPACE}/${DOCKER__ONESPACE}/g"`
    else
        ret=${str_subst_backSlashSpace_inv}
    fi

    #output
   echo "${ret}"
}



#---AUTOCOMPLETE FUNCTION
function autocomplete__func() {
    #Disable Expansion
    disable_expansion__func

    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local keyWord="${1}"
    shift
    local dataArr=("$@")

    #Check if 'keyWord' is an Empty String or Space
    if [[ "${keyWord}" == "${DOCKER__EMPTYSTRING}" ]] || \
                        [[ "${keyWord}" == "${DOCKER__ONESPACE}" ]]; then
        return
    fi

    #Define and update keyWord
    local dataArr_subst=()
    local dataArr_item=${DOCKER__EMPTYSTRING}
    local dataArr_item_escaped=${DOCKER__EMPTYSTRING}
    local dataArr_item_subst=${DOCKER__EMPTYSTRING}
    local dataArr_1stItem_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_init=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch_init=0
    local numOfMatch=0
    local ret=${DOCKER__EMPTYSTRING}

    #***IMPORTANT: Prepend and Substitution within 'dataArr'
    #   Step 1: prepend backslash (\) in front of special chars
    #       Remark:
    #           This is similar to what we would do when inputting the 'query__input'.
    #   Step 2: substitution of the following chars (if present) in the specified sequence (MUST)
    #       Remark:
    #           This is similar to what we would do in subroutine...
    #           ...'compgen__prep_param_and_cmd_handler__sub' to 'query__input'.
    #       1. .\ becomes .
    #       2. \. becomes .
    #       3. ending with . becomes ./
    #       4. \/ becomes /
    #       5. // becomes /
    #       6. \ becomes \\ (which is a double-backslash)

    #Loop thru array-elements and substitute the above mentions chars in the specified sequence
    for dataArr_item in "${dataArr[@]}"
    do
        #Step 1: prepend backslash (\)
        dataArr_item_escaped=`prepend_backSlash_inFrontOf_specialChars__func "${dataArr_item}" "${DOCKER__TRUE}"`

        #Step 2: substitution
        dataArr_item_subst=`subst_a_combo_of_dot_slash_backslash_to_correct_format__func "${dataArr_item_escaped}"`
        
        #Step 3: append element to array
        dataArr_subst+=("${dataArr_item_subst}")
    done

    #Substitute DOUBLE slashes with SINGLE slash (if any)
    keyWord=`echo "${keyWord}" | sed "s/${DOCKER__DOUBLE_ESCAPE_SLASH}*/${DOCKER__ESCAPED_SLASH}/g"`

    #Make a backup of the original 'keyWord' input value
    keyWord_init=${keyWord}

    #Let's use the 1st array-element as reference (it does not really matter which element is used).
    dataArr_1stItem_len=${#dataArr_subst[0]}

    #Get the number of matches specified by 'keyWord'.
    local trailingSlash_isPresent=`checkForMatch_keyWord_within_string__func "${keyWord}" \
                        "${DOCKER__SLASH}" \
                        "${COMPGEN__CHECKFORMATCH_ENDWITH}" \
                        "${DOCKER__EMPTYSTRING}"`
    if [[ ${trailingSlash_isPresent} == false ]]; then  #trailing backslash not found
        checkForMatchType=${COMPGEN__CHECKFORMATCH_STARTWITH}
    else    #trailing backslash found
        #Remove TRAILING slash
        keyWord=`remove_trailingSlash__func "${keyWord}"`

        checkForMatchType=${COMPGEN__CHECKFORMATCH_EXACT}
    fi

    #Get the number of matches based on the specified 'checkForMatchType'
    numOfMatch_init=`get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func "${DOCKER__EMPTYSTRING}" \
                        "${keyWord}" \
                        "${checkForMatchType}" \
                        "${dataArr_subst[@]}"`

    #Find the closest match
    while true
    do
        case "${numOfMatch_init}" in
            ${DOCKER__NUMOFMATCH_0})    #no match
                #Exit loop
                break
                ;;
            ${DOCKER__NUMOFMATCH_1})    #only 1 match, thus 'dataArr_subst' contains only 1 value
                #Update variable
                ret=${dataArr_subst[0]}

                #Exit loop
                break
                ;;
            *)    #multiple matches
                #Backup keyWord
                keyWord_bck=${keyWord}

                #Get keyWord length
                keyWord_bck_len=${#keyWord_bck}

                #Increment keyWord length by 1
                keyWord_len=$((keyWord_bck_len + 1))

                #Get the next keyWord (by using the 1st array-element as base)
                keyWord=${dataArr_subst[0]:0:keyWord_len}

                #Check if the total length of the 1st array-element has been reached
                if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                    ret=${keyWord_bck}

                    break
                fi

                #Get the new number of matches
                numOfMatch=`get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func "${DOCKER__EMPTYSTRING}" \
                        "${keyWord}" \
                        "${COMPGEN__CHECKFORMATCH_STARTWITH}" \
                        "${dataArr_subst[@]}"`

                #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
                if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                    ret=${keyWord_bck}

                    break
                fi
                ;;
        esac
    done

    #Add trailing slash (if originally present)
    if [[ ${trailingSlash_isPresent} == true ]]; then  #trailing backslash not found
        ret=${keyWord_init}
    fi

    #Output:
    #   1. the closest match 'ret'
    #   2. the number of matches 'numOfMatch_init'
    #Remark:
    #   The above mentioned parameter values are separated by 'SED__GS'
    echo "${ret}${SED__GS}${numOfMatch_init}"

    #Enable expansion
    enable_expansion__func
}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

compgen__environmental_variables__sub() {
    compgen__raw_headed_tmp__filename="compgen_raw_headed.tmp"
    compgen__raw_headed_tmp__fpath=${docker__tmp_dir}/${compgen__raw_headed_tmp__filename}
    compgen__raw_headed2_tmp__filename="compgen_raw_headed2.tmp"
    compgen__raw_headed2_tmp__fpath=${docker__tmp_dir}/${compgen__raw_headed2_tmp__filename}
    compgen__raw_headed3_tmp__filename="compgen_raw_headed3.tmp"
    compgen__raw_headed3_tmp__fpath=${docker__tmp_dir}/${compgen__raw_headed3_tmp__filename}
    compgen__raw_backslash_prepended_tmp__filename="compgen_raw_backslash_prepended.tmp"
    compgen__raw_backslash_prepended_tmp__fpath=${docker__tmp_dir}/${compgen__raw_backslash_prepended_tmp__filename}
    compgen__raw_all_tmp__filename="compgen_raw_all.tmp"
    compgen__raw_all_tmp__fpath=${docker__tmp_dir}/${compgen__raw_all_tmp__filename}
    compgen__tablized_tmp__filename="compgen_tablized.tmp"
    compgen__tablized_tmp__fpath=${docker__tmp_dir}/${compgen__tablized_tmp__filename}

    compgen__query_w_autocomplete_out__filename="compgen_query_w_autocomplete.out"
    compgen__query_w_autocomplete_out__fpath=${docker__tmp_dir}/${compgen__query_w_autocomplete_out__filename}
}

compgen__load_constants__sub() {
    COMPGEN__CHECKFORMATCH_ANY=0
    COMPGEN__CHECKFORMATCH_STARTWITH=1
    COMPGEN__CHECKFORMATCH_ENDWITH=2
    COMPGEN__CHECKFORMATCH_EXACT=3

    COMPGEN__COMPGEN_C="compgen -c"  #find executable commands
    COMPGEN__COMPGEN_D="compgen -d"  #find folders
    COMPGEN__COMPGEN_F="compgen -f"  #find files and folders
    COMPGEN__COMPGEN_C_D="compgen -c -d" #find folders, and executable commands
    COMPGEN__COMPGEN_C_F="compgen -c -f" #find files, folders, and executable commands
}

compgen__init_variables__sub() {
    compgen__cachedArr=()
    compgen__cachedArrLen=0

    compgen__docker_exec_cmd="docker exec -t ${containerID__input} ${docker__bin_bash__dir} -c"

    compgen__cmd=${DOCKER__EMPTYSTRING}
    compgen__in=${DOCKER__EMPTYSTRING}    #introduced to take care of the special cases
    compgen__trailStr=${DOCKER__EMPTYSTRING}   #this is the string which on the right=side of the space (if any)
    compgen__out=${DOCKER__EMPTYSTRING}  #this is the result after executing 'autocomplete__func'
    compgen__leadStr=${DOCKER__EMPTYSTRING}   #this is the string which is on the left-side of the space (if any)

    compgen__autocomplete_numOfMatch=0
    compgen__numOfItems_max=0
    compgen__numOfItems_toBeShown=0
    compgen__query_numOfWords=0

    compgen__dup_horizLine=`duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"`
    compgen__print_numOfItems_shown=${DOCKER__EMPTYSTRING}

    compgen_skip_get_results=false

    ret=${DOCKER__EMPTYSTRING} #this is in general the combination of 'leadString' and 'compgen__out' (however exceptions may apply)
}

compgen__delete_tmpFiles__sub() {
    if [[ -f ${compgen__raw_all_tmp__fpath} ]]; then
        rm ${compgen__raw_all_tmp__fpath}
    fi
    if [[ -f ${compgen__raw_headed_tmp__fpath} ]]; then
        rm ${compgen__raw_headed_tmp__fpath}
    fi
    if [[ -f ${compgen__raw_headed2_tmp__fpath} ]]; then
        rm ${compgen__raw_headed2_tmp__fpath}
    fi
    if [[ -f ${compgen__raw_headed3_tmp__fpath} ]]; then
        rm ${compgen__raw_headed3_tmp__fpath}
    fi
    if [[ -f ${compgen__raw_backslash_prepended_tmp__fpath} ]]; then
        rm ${compgen__raw_backslash_prepended_tmp__fpath}
    fi
    if [[ -f ${compgen__tablized_tmp__fpath} ]]; then
        rm ${compgen__tablized_tmp__fpath}
    fi
}

compgen__delete_files__sub() {
    if [[ -f ${output_fPath__input} ]]; then
        rm ${output_fPath__input}
    fi 
}

compgen__prep_param_and_cmd_handler__sub() {
    #query__input: 
    #   substitution of the following chars (if present) in the specified sequence (MUST)
    #       1. .\ becomes .
    #       2. \. becomes .
    #       3. ending with . becomes ./
    #       4. \/ becomes /
    #       5. // becomes /
    #       6. \ becomes \\ (which is a double-backslash)
    # local query_subst=`subst_a_combo_of_dot_slash_backslash_to_correct_format__func "${query__input}"`

    #Retrieve 4 results: compgen__leadStr, compgen__trailStr, compgen__query_numOfWords, compgen__cmd
    local results=`retrieve_leadingStr__compgen_in__and__cmd____func "${query__input}" \
                        "${DOCKER__FALSE}"`

    #Get the results
    #Remark:
    #   This leading string part will have to be prepended to...
    #   ...the return value 'ret' in function 'compgen__get_closest_match__sub'
    compgen__leadStr=`echo "${results}" | cut -d"${SED__GS}" -f1`

    #Get the string part which will be injected into 'compgen'
    compgen__trailStr=`echo "${results}" | cut -d"${SED__GS}" -f2`

    #compgen__leadStr & compgen__trailStr:
    #   substitution of backslash-dot-slash (\./) in the specified sequence (MUST):
    #       1. .\ becomes .
    #       2. \. becomes .
    #       3. ending with . becomes ./
    #       4. \/ becomes /
    #       5. // becomes /
    #       6. \ becomes \\ (which is a double-backslash)
    compgen__leadStr=`subst_a_combo_of_dot_slash_backslash_to_correct_format__func "${compgen__leadStr}"`
    compgen__trailStr=`subst_a_combo_of_dot_slash_backslash_to_correct_format__func "${compgen__trailStr}"`


    #Get number of words
    compgen__query_numOfWords=`echo "${results}" | cut -d"${SED__GS}" -f3`


    #Get compgen command
    compgen__cmd=`echo "${results}" | cut -d"${SED__GS}" -f4`


    #Check if 'compgen__trailStr' contains a leading dash (-)
    local leadingDash_isFound=`checkIf_string_contains_a_leading_specified_chars__func "${compgen__trailStr}" \
                        "${DOCKER__NUMOFCHARS_1}" \
                        "${DOCKER__DASH}"`

    case "${leadingDash_isFound}" in
            ${DOCKER__TRUE})
            compgen__cachedArr=()
            compgen__cachedArrLen=0

            compgen__leadStr=${DOCKER__EMPTYSTRING}
            compgen__out="${query__input}"

            compgen_skip_get_results=true

            return
            ;;
        *)
            ;;
    esac
}

compgen__get_results__sub() {
    #If flag 'compgen_skip_get_results = true', then...
    #...create an empty file and exit this subroutine
    if [[ ${compgen_skip_get_results} == true ]]; then
        touch ${compgen__raw_all_tmp__fpath}

        return
    fi

    #Update compgen__in
    case "${compgen__trailStr}" in
        "${DOCKER__QUADRUPLE_ESCAPED_BACKSLASH}${DOCKER__ONESPACE}")  #equivalent to (\\\\\\\\ ) which is (\\ )
            #MUST set to compgen__cmd = compgen -f (instead of compgen -c -f)
            compgen__cmd=${COMPGEN__COMPGEN_F}

            #MUST change from (\\\\ ) to Empty String. 
            #If not done, executing 'cmd' with (\\\\ ) will not give any result.
            compgen__in=${DOCKER__EMPTYSTRING}
            ;;
        *)  #no special case
            compgen__in=${compgen__trailStr}
            ;;
    esac

    #Define commands
    #Remarks:
    #1. In order to be able to execute commands with SPACES, 'eval' must be used.
    #2. Backslash (\) should be prepended before a quote ('), because otherwise 
    #   the command 'cmd' will not be executed correctly.
    #3. sort: sort result.
    #4. uniq: remove duplicates.
    local cmd="eval ${compgen__cmd} \"${compgen__in}\" | sort | uniq"

    #Execute command
    if [[ -z ${containerID__input} ]]; then
        readarray -t compgen__cachedArr < <(${cmd})
    else
        readarray -t compgen__cachedArr < <(${compgen__docker_exec_cmd} "${cmd}" | tr -d ${DOCKER__CR})
    fi

    #Update array-length
    compgen__cachedArrLen=${#compgen__cachedArr[@]}

    if [[ ${compgen__cachedArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        printf "%s\n" "${compgen__cachedArr[@]}" > ${compgen__raw_all_tmp__fpath}
    else
        touch ${compgen__raw_all_tmp__fpath}
    fi
}

compgen__get_closest_match__sub() {
    #Get closest match
    if [[ ${compgen__cachedArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        #This function outputs 2 values:
        #1. closest match result
        #2. number of matches 'numOfMatch'
        #Both results are separated by a pipe (|)
        local results=`autocomplete__func "${compgen__trailStr}" "${compgen__cachedArr[@]}"`

        #Get results delimited by a pipe (|)
        compgen__out=`echo "${results}" | cut -d"${SED__GS}" -f1`
        compgen__autocomplete_numOfMatch=`echo "${results}" | cut -d"${SED__GS}" -f2`

        #Append compgen__autocomplete_numOfMatch (if 'compgen__out' is a directory)
        if [[ ${compgen__autocomplete_numOfMatch} -eq ${DOCKER__NUMOFMATCH_1} ]]; then   #exactly 1 match
            compgen__out=`append_slash__func "${containerID__input}" "${compgen__out}"`
        fi
    fi

    #Check if 'compgen__out = Empty String'
    case "${compgen__out}" in
        ${DOCKER__EMPTYSTRING}) #is an Empty String
            #Remark:
            #   In this special case when 'compgen__out' is an 'Empty String'...
            #   ...whether 'compgen__trailStr' or 'compgen__leadStr' is an Empty String...
            #   ...and on the other hand 'compgen__leadStr' or 'compgen__trailStr'...
            #   ...contains data...
            #   ...(and vice versa)
            ret="${compgen__leadStr}${compgen__trailStr}"
            ;;
        *)  #is NOT an Empty String
            if [[ ${compgen__query_numOfWords} -eq ${DOCKER__NUMOFMATCH_1} ]]; then #query__input consists of 1 word only
                if [[ ${compgen__autocomplete_numOfMatch} -gt ${DOCKER__NUMOFMATCH_0} ]]; then  #at least one match was found
                    ret="${compgen__out}"
                else    #no match was found
                    ret="${compgen__trailStr}"
                fi
            else    #query_input consists more of 2 words
                ret="${compgen__leadStr}${compgen__out}"
            fi
            ;;
    esac



    # #Write to file
    echo -e "${ret}" > ${output_fPath__input}
}

compgen__show_handler__sub() {
    #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
    if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
        tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
    fi

    #Print Tibbo-title
    load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"

    #Write results to file
    compgen__prep_print__sub

    #Show directory contents
    cat ${compgen__tablized_tmp__fpath}
}
compgen__prep_print__sub() {
    case "${compgen__cachedArrLen}" in
        ${DOCKER__NUMOFMATCH_0})
            compgen__prep_header_print__sub

#-----------Check if there are any results
            #Write empty line to file
            echo "${DOCKER__EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
        
            center_string_and_writeTo_file__func "${DOCKER__ECHOMSG_NORESULTS_FOUND}" "${DOCKER__TABLEWIDTH}" "${compgen__tablized_tmp__fpath}"

            #Write empty lines to file
            echo "${DOCKER__EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
            echo "${DOCKER__EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
            #Write horizontal line to file
            echo "${compgen__dup_horizLine}" >> ${compgen__tablized_tmp__fpath}

            return
            ;;
        *)
#-----------Copy from 'compgen__raw_all_tmp__fpath' to 'compgen__raw_headed_tmp__fpath'...
            #...based on the specified 'table_numOfRows__input'.
            if [[ ${table_numOfRows__input} -eq 0 ]]; then  #copy everything
                cp ${compgen__raw_all_tmp__fpath} ${compgen__raw_headed_tmp__fpath}
            else    #copy a number of lines specified by 'table_numOfRows__input'
                cat ${compgen__raw_all_tmp__fpath} | head -n${table_numOfRows__input} > ${compgen__raw_headed_tmp__fpath}
            fi

#-----------Remove the substring on the left-side of the LAST slash (/) of...
            #...all lines within file 'compgen__raw_headed_tmp__fpath'.
            compgen__prep_print_rem_subString_onLeftSideOf_last_slash__sub 

#-----------Determine the 'word_length_max' and 'compgen__numOfItems_toBeShown'
            #word_length_max: maximum word-length found
            #compgen__numOfItems_toBeShown: number of words found in the file 'compgen_raw.tmp'
            local dirFormat=${DOCKER__EMPTYSTRING}
            local dirFormat_isDirectory=false
            local line=${DOCKER__EMPTYSTRING}
            local line_readyToWrite=${DOCKER__EMPTYSTRING}
            local line_usedTo_meassure=${DOCKER__EMPTYSTRING}
            local line_w_prepended_backslash=${DOCKER__EMPTYSTRING}

            local line_usedTo_meassure_len=0
            local word_length_max=0

            while IFS= read -r line
            do
                #Prepend backslash (\) in front of all special characters (execpt for: dot (.) and slash(/))
                line_w_prepended_backslash=`prepend_backSlash_inFrontOf_specialChars__func \
                        "${line}" \
                        "${DOCKER__TRUE}"`

                #Update 'dirFormat'
                #***IMPORTANT: use 'line' instead of 'line_w_prepended_backslash'
                dirFormat="${compgen__out}/${line}"

                #Check if 'dirFormat' is a directory
                dirFormat_isDirectory=`checkIf_dir_exists__func "${DOCKER__EMPTYSTRING}" "${dirFormat}"`
                if [[ ${dirFormat_isDirectory} == true ]]; then #is a directory
                    #Append slash (/) to 'line_usedTo_meassure'
                    line_usedTo_meassure="${line_w_prepended_backslash}${DOCKER__SLASH}"

                    line_readyToWrite="${line_usedTo_meassure}${SED__ETX}"
                else
                    #Update 'line_usedTo_meassure'
                    line_usedTo_meassure="${line_w_prepended_backslash}"

                    line_readyToWrite="${line_usedTo_meassure}"
                fi
            
                #Write 'line_readyToWrite' to file 'compgen__raw_backslash_prepended_tmp__fpath'
                echo "${line_readyToWrite}" >> ${compgen__raw_backslash_prepended_tmp__fpath}


                #Get length of 'line_usedTo_meassure_len'
                line_usedTo_meassure_len=${#line_usedTo_meassure}

                #Update max 'word' length
                if [[ ${word_length_max} -lt ${line_usedTo_meassure_len} ]]; then
                    word_length_max=${line_usedTo_meassure_len}
                fi


                #Count the number of words in this file
                compgen__numOfItems_toBeShown=$((compgen__numOfItems_toBeShown+1))
            done < ${compgen__raw_headed_tmp__fpath}

#-----------Get 'word_length_max_corr'
            #REMARKS:
            #   DOCKER__SPACE_BETWEEN_WORDS: space between each word
            #   table_leadingSpace_len: leading space of each line
            local table_leadingSpace_len=${#table_leadingSpace__input}
            local word_length_max_corr=$((word_length_max + DOCKER__SPACE_BETWEEN_WORDS + table_leadingSpace_len))

#-----------Get 'table_numOfCols__input'
            #Calculate maximum allowed number of columns
            local numOfCols_calc_max=$((DOCKER__TABLEWIDTH/word_length_max_corr))
            local line_length_max_try=$((word_length_max_corr*numOfCols_calc_max + word_length_max))
            #Finally check if it is possible to add another word with max. length is 'word_length_max'
            if [[ ${line_length_max_try} -le ${DOCKER__TABLEWIDTH} ]]; then #line_length_max_try
                numOfCols_calc_max=$((numOfCols_calc_max + 1))
            fi

            #Check if the number of 'numOfCols_calc_max > DOCKER__TABLECOLS_MAX_7'
            if [[ ${numOfCols_calc_max} -gt ${DOCKER__TABLECOLS_MAX_7} ]]; then
                numOfCols_calc_max=${DOCKER__TABLECOLS_MAX_7}    #set value to 'DOCKER__TABLECOLS_MAX_7'
            fi

#-----------Get 'table_numOfCols__input'
            #Or 'table_numOfCols__input = 0 (auto)'
            if [[ ${table_numOfCols__input} -gt ${numOfCols_calc_max} ]] || \
                    [[ ${table_numOfCols__input} -eq 0 ]]; then
                table_numOfCols__input=${numOfCols_calc_max}
            fi


#-----------Write header to file (must be placed here)
            compgen__prep_header_print__sub

#-----------Add spaces between each column
            local line_colored=${DOCKER__EMPTYSTRING}
            local line_print=${DOCKER__EMPTYSTRING}

            local fileLineNum=0
            local fileLineNum_max=`cat ${compgen__raw_backslash_prepended_tmp__fpath} | wc -l`
            local line_print_numOfWords=0

            #Go through each line of the file
            #Remark:
            #   Each line contains a string which is one-word in length.
            while IFS= read -r line
            do
                #Increment by 1
                fileLineNum=$((fileLineNum + 1))
                line_print_numOfWords=$((line_print_numOfWords + 1))

                #Check if 'string__input' already contains any trailing 'SED__ETX'
                #Note: if 'SED__EXT' is found, then apply color.
                local trailingEtx_isFound=`checkIf_string_contains_a_trailing_specified_chars__func \
                        "${line}" \
                        "${DOCKER__NUMOFCHARS_1}" \
                        "${SED__ETX}"`
                if [[ ${trailingEtx_isFound} == true ]]; then
                    #Apply color to 'line'
                    line_colored="${DOCKER__FG_ORANGE208}${line}${DOCKER__NOCOLOR}"
        
                    #Get the length of 'line_colored' without color-regex
                    line_length=`get_stringlen_wo_regEx__func "${line_colored}"`

                    #***IMPORTANT: Substract (-1) due to the presence of 'SED__ETX'
                    line_length=$((line_length - 1))
                else
                    #Update 'line_colored'
                    line_colored="${line}"

                    #Get the length of 'line_colored' without color-regex
                    line_length=`get_stringlen_wo_regEx__func "${line_colored}"`
                fi

                #Set 'word' to be printed
                if [[ ${line_print_numOfWords} -eq 1 ]]; then
                    line_print="${table_leadingSpace__input}${line_colored}"
                else
                    line_print="${line_print}${line_colored}" 
                fi

                
                #Calculate the gap to be appended.
                #Remark:
                #   This is the gap between each column.
                if [[ ${fileLineNum} -lt ${fileLineNum_max} ]]; then
                    #Calculate the gap-length
                    gap_length=$((word_length_max_corr - line_length))
                    #Generate the spaces based on the specified 'gap_length'
                    gap_string=`duplicate_char__func "${DOCKER__ONESPACE}" "${gap_length}" `

                    #Append the 'gap_string' to 'line_print'
                    line_print=${line_print}${gap_string}
                fi

                #Write to file
                #Remarks:
                #   Only do this when:
                #   1. line_print_numOfWords = table_numOfCols__input
                #   OR
                #   2. fileLineNum = fileLineNum_max
                if [[ ${line_print_numOfWords} -eq ${table_numOfCols__input} ]] || [[ ${fileLineNum} -eq ${fileLineNum_max} ]]; then
                    #write to file
                    echo "${line_print}" >> ${compgen__tablized_tmp__fpath}

                    #Reset line_print_numOfWords
                    line_print_numOfWords=0   

                    #Reset string
                    line_print=${DOCKER__EMPTYSTRING}
                fi
            done < ${compgen__raw_backslash_prepended_tmp__fpath}
            ;;
    esac

#---Finalizing print
    #Write empty line to file
    echo "${DOCKER__EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
    #Write horizontal line to file
    echo "${compgen__dup_horizLine}" >> ${compgen__tablized_tmp__fpath}
}
compgen__prep_header_print__sub() {
    #Get maximum number of results
    compgen__numOfItems_max=`cat ${compgen__raw_all_tmp__fpath} | wc -l`

    #Update variable
    compgen__print_numOfItems_shown="(${DOCKER__FG_ORANGE208}${compgen__numOfItems_toBeShown}${DOCKER__NOCOLOR} "
    compgen__print_numOfItems_shown+="out-of ${DOCKER__FG_ORANGE203}${compgen__numOfItems_max}${DOCKER__NOCOLOR})"

    compgen__listOfKeyWord="${table_leadingSpace__input}${DOCKER__FG_ORANGE208}List of keyword ${DOCKER__NOCOLOR} "
    compgen__listOfKeyWord+="<${DOCKER__FG_ORANGE203}${query__input}${DOCKER__NOCOLOR}> ${compgen__print_numOfItems_shown}"

    #Print message showing which directory's content is being shown
    echo "${compgen__dup_horizLine}" >> ${compgen__tablized_tmp__fpath}
    echo "${compgen__listOfKeyWord}" >> ${compgen__tablized_tmp__fpath}
    echo "${compgen__dup_horizLine}" >> ${compgen__tablized_tmp__fpath}
}
compgen__prep_print_rem_subString_onLeftSideOf_last_slash__sub() {
    #Remark:
    #   To give an idea what is meant with 'leading string ending /w slash',...
    #   ...please take a look at the following examples:
    #   ./../
    #   .././
    #   /tmp/
    #   /home/imcase/

    ##Get substring on the LEFT-side of the LAST slash (/)...
    cat "${compgen__raw_headed_tmp__fpath}" | rev | cut -d"${DOCKER__SLASH}" -f2- | rev |  sort | uniq > ${compgen__raw_headed3_tmp__fpath}

    #Check the number of lines in file 'compgen__raw_headed3_tmp__fpath'
    #Remark:
    #   1. if 'numOfLines = 1', then it means that all files/folders are in the same directory.
    #   2. if 'numOfLines > 1', then it means that all files/folders are in different directories...
    #      ...OR...
    #      ...file-contents of file 'compgen__raw_headed2_tmp__fpath' are not files/folders, but commands.
    #      
    local numOfLines=`cat "${compgen__raw_headed3_tmp__fpath}" | wc -l`
    if [[ ${numOfLines} -gt ${DOCKER__NUMOFMATCH_1} ]]; then    #file contains more than 1 line
        return
    else    #file contains only 1 line
        #Get file-content
        local fileContent=`cat "${compgen__raw_headed3_tmp__fpath}"`
        #Check if 'fileContent' is an Empty String, then it means that all files/folders are in the main directory (/).
        if [[ "${fileContent}" == "${DOCKER__EMPTYSTRING}" ]]; then
            return
        fi
    fi

    #Get substring on the RIGHT-side of the LAST slash (/)...
    #...within the lines of file 'compgen__raw_headed2_tmp__fpath'
    cat "${compgen__raw_headed_tmp__fpath}" | rev | cut -d"${DOCKER__SLASH}" -f1 | rev > ${compgen__raw_headed2_tmp__fpath}

    #Update 'compgen__raw_headed_tmp__fpath'
    cp ${compgen__raw_headed2_tmp__fpath} ${compgen__raw_headed_tmp__fpath}    
}




#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    compgen__environmental_variables__sub

    compgen__load_constants__sub

    compgen__init_variables__sub

    compgen__delete_tmpFiles__sub
    compgen__delete_files__sub

    compgen__prep_param_and_cmd_handler__sub

    compgen__get_results__sub

    compgen__get_closest_match__sub

    compgen__show_handler__sub
}



#---EXECUTE MAIN
main__sub
