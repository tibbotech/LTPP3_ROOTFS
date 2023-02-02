#!/bin/bash
#---INPUT ARGS
isstring=${1}

#---ENVIRONMENT CONSTANTS
NTIOS_SU_ADD_MONITOR="ntios-su-add-monitor"
NTIOS_SU_ADD_MONITOR_SERVICE="${NTIOS_SU_ADD_MONITOR}.service"
NTIOS_SU_ADD_MONITOR_TIMER="${NTIOS_SU_ADD_MONITOR}.timer"
SUDO="sudo"
SUDOERS="sudoers"
TIBBO="tibbo"
ETC_DIR="/etc"
ETC_TIBBO_SUDO_DIR="/${ETC_DIR}/${TIBBO}/${SUDO}"
ETC_SUDOERS_FPATH="${ETC_DIR}/${SUDOERS}"
ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH="${ETC_TIBBO_SUDO_DIR}/${SUDOERS}.org"

#---PATTERN CONSTANTS
PATTERN_GREP="grep"
PATTERN_HASH_PID_COLON="#PID:"

#---VARIABLES
user="ubuntu"



#---FUNCTIONS
IsNumeric() {
    #Input args
    local isval=${1}

    #Define variables
    local ret=false

    #Check if numeric
    if  [[ "${isval}" = *([+-])*([0-9])*(.)*([0-9]) ]]; then
        ret=true
    else
        ret=false 
    fi

    #Output
    echo "${ret}"

    return 0;
}

Sudoers_Backup() {
    if [[ -f "${ETC_SUDOERS_FPATH}" ]]; then
        cp "${ETC_SUDOERS_FPATH}" "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}"
    fi
}
Sudoers_Restore() {
    if [[ -f "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}" ]]; then
        cp "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}" "${ETC_SUDOERS_FPATH}"
    fi
}

Services_EnableStart() {
    #Enable Services
    systemctl enable "${NTIOS_SU_ADD_MONITOR_SERVICE}"
    systemctl enable "${NTIOS_SU_ADD_MONITOR_TIMER}"


    #Start Services
    systemctl start "${NTIOS_SU_ADD_MONITOR_TIMER}"
}


#---MAIN SUBROUTINE
main() {
    #Define variables
    local line_nohex_isfound="${EMPTYSTRING}"
    local line_nohex="${EMPTYSTRING}"
    local line="${EMPTYSTRING}"
    local pid=0
    local sudoers_isclean="${EMPTYSTRING}"
    local isstring_isnumeric=false

    #Make dir if not exist
    if [[ ! -d "${ETC_TIBBO_SUDO_DIR}" ]]; then
        mkdir -p "${ETC_TIBBO_SUDO_DIR}"
    fi

    #Backup '/etc/sudoers' as /'etc/tibbo/sudo/sudoers.org'
    if [[ ! -f "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}" ]]; then
        #Check if '/etc/sudoers' is clean, which means does not contain
        #...any '#PID:' entry.
        sudoers_isclean=$(grep "${PATTERN_HASH_PID_COLON}" "${ETC_SUDOERS_FPATH}")
        if [[ -z "${sudoers_isclean}" ]]; then
            Sudoers_Backup
        fi
    fi


    #Check if 'isstring' is numeric
    #Remark:
    #   If that's the case then, 'isstring' is a PID
    isstring_isnumeric=$(IsNumeric "${isstring}")
    if [[ "${isstring_isnumeric}" == true ]]; then
        #Restore file
        Sudoers_Restore

        #Write an empty line to file
        echo "${EMPTYSTRING}" | tee -a "${ETC_SUDOERS_FPATH}" 1>/dev/null

        #Update 'pid'
        pid=${isstring}

        #Compose 'line' which will be written to '/etc/sudoers'
        line="${PATTERN_HASH_PID_COLON}${pid}"

        #Write 'line' to file
        echo "${line}" | tee -a "${ETC_SUDOERS_FPATH}" 1>/dev/null

        #Enable & Start services
        Services_EnableStart

        #exit script
        exit
    fi


    #Compose 'line' which contains the fullpath of
    #...a command specified by 'isstring'
    line="${user}  ALL=(root) NOPASSWD: ${isstring}"
    #Convert all hex to ascii values
    line_nohex=$(echo -e ${line})
    #Check if 'line_nohex' is already added to '/etc/sudoers'
    line_nohex_isfound=$(grep "${line_nohex}" "${ETC_SUDOERS_FPATH}")
    if [[ -z "${line_nohex_isfound}" ]]; then  #string is not found
        echo -e "${line_nohex}" | tee -a "${ETC_SUDOERS_FPATH}" >/dev/null
    fi
}



#---EXECUTE MAIN
main
