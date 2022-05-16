#!/bin/bash
#Input args
containerID__input=${1}
query__input=${2}
table_numOfRows__input=${3}
table_numOfCols__input=${4}
output_fPath__input=${5}



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
    #1. (\ ) to \x02backslashspace\x03
    local str_subst_backSlashSpace=`echo "${string__input}" | \
                        sed "s/${DOCKER__TRIPLE_ESCAPED_BACKSLASH}${DOCKER__ONESPACE}/${SED_SUBST_BACKSLASHSPACE}/g"`

    #2. (\t) to \x02slasht\x03
    local str_subst_backslashT=`echo "${str_subst_backSlashSpace}" | \
                        sed "s/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}${DOCKER__ESCAPED_T}/${SED_SUBST_BACKSLASHT}/g"`

    #3. (\) to \x02backslash\x03
    local str_subst_backslash=`echo "${str_subst_backslashT}" | \
                        sed "s/${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}/${SED_SUBST_BACKSLASH}/g"`

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
    #1. \x02backslash\x03 to (\)
    local str_subst_backslash_inv=`echo "${string__input}" | \
                        sed "s/${SED_SUBST_BACKSLASH}/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}/g"`

    #2.  \x02slasht\x03 to (\t)
    local str_subst_backslashT_inv=`echo "${str_subst_backslash_inv}" | \
                        sed "s/${SED_SUBST_BACKSLASHT}/${DOCKER__DOUBLE_ESCAPED_BACKSLASH}${DOCKER__ESCAPED_T}/g"`

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
docker__environmental_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}

    docker__dockerfile_auto_filename="dockerfile_auto"
    docker__dockerfile_autogen_fpath=${DOCKER__EMPTYSTRING}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

compgen__environmental_variables__sub() {
    >>>NEED TO BE ADDED
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

    COMPGEN__TRIM_CR="tr -d ${DOCKER__CR}"

    SED_SUBST_BACKSLASHSPACE="${SED__STX}backslashspace${SED__ETX}"
    SED_SUBST_BACKSLASH="${SED__STX}backslash${SED__ETX}"
    SED_SUBST_SPACE="${SED__STX}space${SED__ETX}"
    SED_SUBST_BACKSLASHT="${SED__STX}backslasht${SED__ETX}"
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
    >>>NEED TO BE ADDED
}

compgen__delete_files__sub() {
    >>>NEED TO BE ADDED
}

compgen__prep_param_and_cmd_handler__sub() {
    >>>NEED TO BE ADDED
}

compgen__get_results__sub() {
    >>>NEED TO BE ADDED 
}

compgen__get_closest_match__sub() {
    >>>NEED TO BE ADDED
}

compgen__show_handler__sub() {
    #Write results to file
    compgen__prep_print__sub

    #Show directory contents
    cat ${compgen__tablized_tmp__fpath}
}
compgen__prep_print__sub() {
    >>>NEED TO BE ADDED
}
compgen__prep_header_print__sub() {
    >>>NEED TO BE ADDED
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

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
