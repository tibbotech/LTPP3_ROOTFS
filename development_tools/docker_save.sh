#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
	if [[ -z ${docker__parent_dir} ]]; then
		docker__parent_dir="${AUTOCOMPLETE__SLASH_CHAR}"
	fi

    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images

    docker__current_folder=`basename ${docker__current_dir}`
    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__create_dirs__sub() {
    #Create directory if not present
    if [[ ! -d ${docker__images_dir} ]]; then
        mkdir -p ${docker__images_dir}
    fi
}

docker__save_handler__sub() {
    #Define local constants
    local MENUTITLE="Export an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"

    #Define local message constants
    local ECHOMSG_IMAGE_LOCATION="${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} Location: "

    #Define local read-input constants
    local READMSG_CHOOSE_A_REPOSITORY_FROM_LIST="Choose a ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR} from list (e.g. ubuntu_buildbin): "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n)? "    #Define local command variables
    local READMSG_PROVIDE_ITS_CORRESPONDING_TAG="Provide its matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. latest): "

    #Define local variables
    local myRepository=${DOCKER__EMPTYSTRING}
    local myTag=${DOCKER__EMPTYSTRING}
    local myImageId=${DOCKER__EMPTYSTRING}

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"



    #Show Image-list
    docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_image_ls_cmd}"

    #Loop
    while true
    do
        read -e -p "${READMSG_CHOOSE_A_REPOSITORY_FROM_LIST}" myRepository
        if [[ ! -z ${myRepository} ]]; then

            myRepository_isFound=`docker image ls | awk '{print $1}' | grep -w "${myRepository}"`
            if [[ ! -z ${myRepository_isFound} ]]; then
                while true
                do        
                    #Find tag belonging to 'myRepository' (Exact Match)
                    myTag=$(docker image ls | grep -w "${myRepository}" | awk '{print $2}')

                    #Request for TAG input
                    read -e -p "${READMSG_PROVIDE_ITS_CORRESPONDING_TAG}" -i ${myTag} myTag
                    if [[ ! -z ${myTag} ]]; then    #input was NOT an EMPTY STRING

                        #check if 'myRepository' and 'myTag' are a matching pair
                        myTag_isFound=`docker image ls | grep -w "${myRepository}" | grep -w "${myTag}"`
                        if [[ ! -z ${myTag_isFound} ]]; then    #match was found
                            #Get Image-ID
                            myImageId=`docker image ls | grep -w "${myRepository}" | grep -w "${myTag}" | awk '{print $3}'`

                            #Compose Image full-path
                            docker__image_fpath="${docker__images_dir}/${myRepository}_${myTag}_${myImageId}.tar.gz"
                            
                            while true
                            do
                                echo -e "${ECHOMSG_IMAGE_LOCATION}"
                                
#-------------------------------This part has been implemented to make sure that the file-location...
#-------------------------------is not shown on the last terminal line
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                                
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#-------------------------------This part has been implemented to make sure that the file-location...
#-------------------------------is not shown on the last terminal line
                                                    
                                echo -e "${DOCKER__FG_LIGHTGREY}"
                                read -e -p "${DOCKER__FOURSPACES}" -i "${docker__image_fpath}" myOutput_fPath
                                echo -e "${DOCKER__NOCOLOR}"

                                if [[ ! -z ${myOutput_fPath} ]]; then
                                    
                                    myOutput_dir=`dirname ${myOutput_fPath}`
                                    if [[ -d ${myOutput_dir} ]]; then
                                        while true
                                        do
                                            read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" myAnswer
                                            if  [[ ${myAnswer} == "y" ]]; then
                                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                                                echo -e "---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                                                echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Depending on the image size..."
                                                echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: This may take a while..."
                                                echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."
                                                
                                                docker image save --output ${myOutput_fPath} ${myRepository}:${myTag} > /dev/null

                                                echo -e "---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                                                
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
                                        errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Directory '${DOCKER__FG_LIGHTGREY}${myOutput_dir}${DOCKER__NOCOLOR}' not found"

                                        docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"

                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"  
                                    fi
                                else    #Empty String
                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_4}"  
                                fi

                                #Answer was 'no'
                                if  [[ ${myAnswer} == "n" ]]; then
                                    break
                                fi
                            done
                        else
                            errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Un-matched pair ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR} <-> ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR}"
                            
                            docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"

                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"            
                        fi
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi

                    #Answer was 'no'
                    if  [[ ${myAnswer} == "n" ]]; then
                        break
                    fi
                done
            else
                errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: repository '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}' not found"

                docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
            fi 
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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
    
    ${docker__repolist_tableinfo_fpath}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
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

    docker__create_dirs__sub

    docker__save_handler__sub

}



#---EXECUTE
main_sub
