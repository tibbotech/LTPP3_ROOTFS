#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__CONTAINER_BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__REMOVE_ALL="REMOVE-ALL"

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    # echo -e "Exiting now..."
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

function duplicate_char__func() {
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function show_centered_string__func() {
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}



#---SUBROUTINES
CTRL_C__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    
    exit 99
}

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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myContainerId=${DOCKER__EMPTYSTRING}
    docker__myContainerId_input=${DOCKER__EMPTYSTRING}
    docker__myContainerId_subst=${DOCKER__EMPTYSTRING}
    docker__myContainerId_arr=()
    docker__myContainerId_item=${DOCKER__EMPTYSTRING}
    docker__myContainerId_isFound=${DOCKER__EMPTYSTRING}
    docker__myAnswer=${DOCKER__EMPTYSTRING}
}

docker_remove_specified_containers__sub() {
    #Define local constants
    local MENUTITLE="Remove ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (y/n/q/b)? "

    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

    #Define local variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local numof_containers=0

    #Define local command variables
    local docker_ps_a_cmd="docker ps -a"



#---Show Docker Container's List
    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_CONTAINERS_FOUND}"
    else
        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_ps_a_cmd}"
    fi

    #Start loop
    while true
    do
        #Input CONTAINERID(s) which you want to REMOVE
        #REMARK: subroutine 'docker_containerId_input__func' will output variable 'docker__myContainerId'
        docker_containerId_input__func

        if [[ ! -z ${docker__myContainerId} ]]; then
            #Substitute COMMA with SPACE
            docker__myContainerId_subst=`echo ${docker__myContainerId} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myContainerId_arr=(${docker__myContainerId_subst})"

            #Go thru each array-item
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            while true
            do
                read -N1 -p "${READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE}" docker__myAnswer
                if [[ ! -z ${docker__myAnswer} ]]; then          
                    if [[ ${docker__myAnswer} == "y" ]]; then
                        if [[ ${docker__myContainerId} == ${DOCKER__REMOVE_ALL} ]]; then
                            docker kill $(docker ps -q)    #kill all RUNNING containers
                            docker rm $(docker ps -a -q)   #Delete ALL STOPPED containers
                        else
                            for docker__myContainerId_item in "${docker__myContainerId_arr[@]}"
                            do 
                                docker__myContainerId_isFound=`docker ps -a | awk '{print $1}' | grep -w ${docker__myContainerId_item}`
                                if [[ ! -z ${docker__myContainerId_isFound} ]]; then
                                    docker container rm -f ${docker__myContainerId_item}

                                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                                    echo -e "Removed Container-ID: ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__myContainerId_item}${DOCKER__NOCOLOR}"
                                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                                    echo -e "Removing ALL unlinked images"
                                    echo -e "y\n" | docker image prune
                                    echo -e "Removing ALL stopped containers"
                                    echo -e "y\n" | docker container prune           
                                else
                                    #Update error-message
                                    errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid Container-ID: ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__myContainerId_item}${DOCKER__NOCOLOR}"
                                    
                                    #Show error-message
                                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                    docker__show_errMsg_without_menuTitle__func "${errMsg}"
                                fi

                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            done
                        fi

                        #Get number of containers
                        numof_containers=`docker ps -a | head -n -1 | wc -l`
                        if [[ ${numof_containers} -eq 0 ]]; then
                            docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_CONTAINERS_FOUND}"

                            exit
                        else
                            docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker_ps_a_cmd}"

                            break
                        fi
                    elif [[ ${docker__myAnswer} == "n" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    #mandatory to add this empty-line

                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    elif [[ ${docker__myAnswer} == "q" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        exit
                    elif [[ ${docker__myAnswer} == "b" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    #mandatory to add this empty-line

                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    else
                        if [[ ${docker__myAnswer} != "${DOCKER__ENTER}" ]]; then
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        else
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
            done
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"
        fi
    done
}
docker_containerId_input__func() {
    #RESET VARIABLE (IMPORTANT)
    if [[ ${docker__myAnswer} != "b" ]]; then
        docker__myContainerId=${DOCKER__EMPTYSTRING}
    else
        if [[ ${docker__myContainerId} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myContainerId=${DOCKER__EMPTYSTRING}
        fi
    fi


    while true
    do
        echo -e "${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}"
        echo -e "- Remove ALL container-IDs by typing: ${DOCKER__REMOVE_ALL}"
        echo -e "- Multiple container-IDs can be removed"
        echo -e "- Comma-separator will be auto-appended (e.g. 3e2226b5fb4c,78ae00114c5a)"
		echo -e "- [On an Empty Field] press ENTER to confirm deletion"
        echo -e "${DOCKER__CONTAINER_BG_BRIGHTPRUPLE}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}container-IDs${DOCKER__NOCOLOR}:${DOCKER__CONTAINER_BG_BRIGHTPRUPLE}${DOCKER__OUTSIDE_FG_WHITE}${docker__myContainerId}${DOCKER__NOCOLOR}"
        read -e -p "Paste your input (here): " docker__myContainerId_input

        if [[ -z ${docker__myContainerId_input} ]]; then
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

			break
        elif [[ ${docker__myContainerId_input} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myContainerId="${docker__myContainerId_input}"

			break
        else
            if [[ -z ${docker__myContainerId} ]]; then
                docker__myContainerId="${docker__myContainerId_input}"
            else
                docker__myContainerId="${docker__myContainerId},${docker__myContainerId_input}"
            fi

			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
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
    
    if [[ ${dockerCmd} == ${docker_ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}
    else
        ${dockerCmd}
    fi

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function docker__show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    press_any_key__func

    CTRL_C__sub
}

function docker__show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${errMsg}"

    press_any_key__func
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker_remove_specified_containers__sub
}



#---EXECUTE
main_sub