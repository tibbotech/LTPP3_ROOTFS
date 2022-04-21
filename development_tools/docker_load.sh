#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#--SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi

    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images
    docker__image_fPath=${DOCKER__EMPTYSTRING}

    docker__current_folder=`basename ${docker__current_dir}`
    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__import_handler__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__FG_YELLOW}Import${DOCKER__NOCOLOR} an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

    #Define local message constants
    local ECHOMSG_IMAGE_LOCATION="${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} Location: "
    local ERRMSG_NO_IMAGES_FILES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FILES FOUND${DOCKER__NOCOLOR}:="

    #Define local read-input constants
    local READMSG_YOUR_CHOICE="Your choice: "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n)? "    #Define local command variables

    #Define local variables
    local imageList_fPath_arrItem=${DOCKER__EMPTYSTRING}
    local imageList_filename=${DOCKER__EMPTYSTRING}
    local myChoice=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local locationMsg_dockerFiles="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__images_dir}"

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get all files at the specified location
    local imageList_fPath_string=`find ${docker__images_dir} -maxdepth 1 -type f`
    local imageList_fPath_arrItem=${DOCKER__EMPTYSTRING}

    #Check if '' is an EMPTY STRING
    if [[ -z ${imageList_fPath_string} ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        show_centered_string__func "${ERRMSG_NO_IMAGES_FILES_FOUND}" "${DOCKER__TABLEWIDTH}"
    else
        #Convert string to array (with space delimiter)
        local imageList_fPath_arr=(${imageList_fPath_string})

        #Initial sequence number
        local seqNum=1

        #Show all files
        for imageList_fPath_arrItem in "${imageList_fPath_arr[@]}"
        do
            #Get filename only
            imageList_filename=`basename ${imageList_fPath_arrItem}`  
        
            #Show filename
            echo -e "${DOCKER__FOURSPACES}${seqNum}. ${imageList_filename}"

            #increment sequence-number
            seqNum=$((seqNum+1))
        done
    fi

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${locationMsg_dockerFiles}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}m. Manual input"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__Q_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Choose an option
    while true
    do
        while true
        do
            #Show read-input
            if [[ ${seqNum} -le ${DOCKER__NINE} ]]; then    #seqNum <= 9
                read -N1 -p "${READMSG_YOUR_CHOICE} " myChoice
            else    #seqNum > 9
                read -e -p "${READMSG_YOUR_CHOICE} " myChoice
            fi

            #Check if 'myChoice' is a numeric value
            if [[ ${myChoice} =~ [1-90mq] ]]; then
                #check if 'myChoice' is one of the numbers shown in the overview...
                #... AND 'myChoice' is NOT '0'
                if [[ ${myChoice} -lt ${seqNum} ]] && [[ ${myChoice} -ne 0 ]]; then
                    arrNum=$((myChoice-1))
                    myOutput_fPath=${imageList_fPath_arr[${arrNum}]}

                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    echo -e "${ECHOMSG_IMAGE_LOCATION}"

#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    
                    echo -e "${DOCKER__FG_LIGHTGREY}"
                    read -e -p "${DOCKER__FOURSPACES}" -i "${myOutput_fPath}" myOutput_fPath
                    echo -e "${DOCKER__NOCOLOR}"

                    break

                elif [[ ${myChoice} == "m" ]]; then
                    myOutput_fPath=${imageList_fPath_arr[0]}  #'imageList_fPath_arr' contains the full-path

                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    echo -e "${ECHOMSG_IMAGE_LOCATION}"

#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line

                    echo -e "${DOCKER__FG_LIGHTGREY}"
                    read -e -p "${DOCKER__FOURSPACES}" -i "${myOutput_fPath}" myOutput_fPath
                    echo -e "${DOCKER__NOCOLOR}"

                    break

                elif [[ ${myChoice} == "q" ]]; then
                    CTRL_C__sub

                else
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"   

                fi
            else    #for all other keys
                if [[ ${myChoice} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                else    #ENTER was pressed
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
            fi
        done

        #Double-check if chosen image-file still exist
        if [[ -f ${myOutput_fPath} ]]; then
            while true
            do
                read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" myAnswer
                if  [[ ${myAnswer} == "y" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    echo -e "---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: Loading image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Depending on the image size..."
                    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: This may take a while..."
                    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."

                        docker image load --input ${myOutput_fPath} > /dev/null

                    echo -e "---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Loading image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"

                    #Show Docker Image List
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker_image_ls_cmd}"
                    
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    exit

                elif  [[ ${myAnswer} == "n" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"

                    break
                else    #Empty String
                    if [[ ${myAnswer} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    else    #ENTER was pressed
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                fi
            done
        else    #directory does NOT exist
            errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}' not found"

            docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"

            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_9}"
        fi
    done
}

function docker__show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    ${docker__repolist_tableinfo__fpath}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__QUIT_CTR_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function docker__show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}
    local numOf_lines_toBe_movedDown=${2}

    #Move-Down and Clean Lines
    #REMARK: actually the lines do not need to be cleaned
    moveDown_and_cleanLines__func ${numOf_lines_toBe_movedDown}

    #Show error-message
    echo -e "${errMsg}"

    press_any_key__func
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__import_handler__sub
}



#---EXECUTE
main_sub
