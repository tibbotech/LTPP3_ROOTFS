#!/bin/bash
#Input args
containerID__input=${1}
query__input=${2}
table_numOfRows__input=${3}
table_numOfCols__input=${4}
output_fPath__input=${5}



#---FUNCTIONS
>>> ALL FUNCTIONS NEED TO BE ADDED


#---AUTOCOMPLETE FUNCTION
function autocomplete__func() {
>>>NEED TO BE ADDED
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
    tmp_dir=/tmp
    compgen__raw_headed_tmp__filename="compgen_raw_headed.tmp"
    compgen__raw_headed_tmp__fpath=${tmp_dir}/${compgen__raw_headed_tmp__filename}
    compgen__raw_headed2_tmp__filename="compgen_raw_headed2.tmp"
    compgen__raw_headed2_tmp__fpath=${tmp_dir}/${compgen__raw_headed2_tmp__filename}
    compgen__raw_headed3_tmp__filename="compgen_raw_headed3.tmp"
    compgen__raw_headed3_tmp__fpath=${tmp_dir}/${compgen__raw_headed3_tmp__filename}
    compgen__raw_backslash_prepended_tmp__filename="compgen__raw_backslash_prepended.tmp"
    compgen__raw_backslash_prepended_tmp__fpath=${tmp_dir}/${compgen__raw_backslash_prepended_tmp__filename}
    compgen__raw_all_tmp__filename="compgen_raw_all.tmp"
    compgen__raw_all_tmp__fpath=${tmp_dir}/${compgen__raw_all_tmp__filename}
    compgen__tablized_tmp__filename="compgen_tablized.tmp"
    compgen__tablized_tmp__fpath=${tmp_dir}/${compgen__tablized_tmp__filename}

    docker__tmp_dir=/tmp
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
