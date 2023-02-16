#!/bin/bash
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define variables
    local docker__tmp_dir="${EMPTYSTRING}"

    local docker__development_tools__foldername="${EMPTYSTRING}"
    local docker__LTPP3_ROOTFS__foldername="${EMPTYSTRING}"
    local docker__global__filename="${EMPTYSTRING}"
    local docker__parentDir_of_LTPP3_ROOTFS__dir="${EMPTYSTRING}"

    local docker__mainmenu_path_cache__filename="${EMPTYSTRING}"
    local docker__mainmenu_path_cache__fpath="${EMPTYSTRING}"

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem="${EMPTYSTRING}"
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__find_path_of_development_tools="${EMPTYSTRING}"

    #Set variables
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    #Check if file exists
    if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
        #Get the line of file
        docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")
    else
        #Start loop
        while true
        do
            #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
            #... and read to array 'find_result_arr'
            readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

            #Iterate thru each array-item
            for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
            do
                #Update variable 'docker__find_path_of_development_tools'
                docker__find_path_of_development_tools="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                #Check if 'directory' exist
                if [[ -d "${docker__find_path_of_development_tools}" ]]; then    #directory exists
                    #Update variable
                    #Remark:
                    #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                    #   This variable will be passed 'globally' to script 'docker_global.sh'.
                    docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_development_tools}"

                    break
                fi
            done

            #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
            if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                echo -e "\r"

                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"

                echo -e "\r"

                exit 99
            else    #contains data
                break
            fi
        done

        #Write to file
        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null
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

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker___env_var__sub() {
    docker__home_dir=~
    docker__tmp_dir=/tmp
    docker__SP7021_foldername="SP7021"
    docker__SP7021_dir=${docker__home_dir}/${docker__SP7021_foldername}
    docker__SP7021_boot_uboot_tools_dir=${docker__SP7021_dir}/boot/uboot/tools

    docker_build_ispboootbin_tmp_sh_filename="docker_build_ispboootbin_tmp.sh"
    docker_build_ispboootbin_tmp_sh_fpath="${docker__tmp_dir}/${docker_build_ispboootbin_tmp_sh_filename}"
}

docker__create_script__sub() {
    #Generate file-content
    local filecontent="echo -e \"\\r\"\n"
    filecontent+="echo -e \"\\r\"\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: navigate to ${DOCKER__FG_LIGHTGREY}${docker__SP7021_dir}${DOCKER__NOCOLOR}\"\n"
    filecontent+="cd ${docker__SP7021_dir}\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: add to ${DOCKER__FG_LIGHTGREY}${docker__SP7021_boot_uboot_tools_dir}${DOCKER__NOCOLOR} to ${DOCKER__FG_LIGHTGREY}PATH${DOCKER__NOCOLOR}\"\n"
    filecontent+="export PATH=\$PATH:${docker__SP7021_boot_uboot_tools_dir}\n"
    filecontent+="\n"
    filecontent+="checkif_matchisFound=\$(cat ${docker__home_dir}/.bashrc | grep \"${docker__SP7021_boot_uboot_tools_dir}\")\n"
    filecontent+="if [[ -z \"\${checkif_matchisFound}\" ]]; then\n"
    filecontent+="    echo -e \"export PATH=\$PATH:${docker__SP7021_boot_uboot_tools_dir}\" | tee -a ${docker__home_dir}/.bashrc\n"
    filecontent+="fi\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: excecute ${DOCKER__FG_LIGHTGREY}source ${docker__home_dir}/.bashrc${DOCKER__NOCOLOR}\"\n"
    filecontent+="source ${docker__home_dir}/.bashrc\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: excecute ${DOCKER__FG_LIGHTGREY}env \"PATH=\$PATH\" make all${DOCKER__NOCOLOR}\"\n"
    filecontent+="env \"PATH=\$PATH\" make all"

    #Remove file
    if [[ -f "${docker_build_ispboootbin_tmp_sh_fpath}" ]]; then
        rm "${docker_build_ispboootbin_tmp_sh_fpath}"
    fi

    #Write to file
    echo -e "${filecontent}" | tee "${docker_build_ispboootbin_tmp_sh_fpath}" >/dev/null

    #Make file executable
    chmod +x "${docker_build_ispboootbin_tmp_sh_fpath}"
}

docker__execute_scripts__sub() {
    eval "${docker_build_ispboootbin_tmp_sh_fpath}"
}



#---MAIN SUBROUTINE
docker__main__sub() {
    docker__get_source_fullpath__sub
    docker__load_source_files__sub

    docker___env_var__sub

    docker__create_script__sub
    docker__execute_scripts__sub
}



#---MAIN EXECUTE
docker__main__sub
