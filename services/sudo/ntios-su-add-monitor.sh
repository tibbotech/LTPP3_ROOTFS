#!/bin/bash
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
Sudoers_Restore() {
    if [[ -f "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}" ]]; then
        cp "${ETC_TIBBO_SUDO_SUDOERS_ORG_FPATH}" "${ETC_SUDOERS_FPATH}"
    fi
}

Services_DisableStop() {
    #Disable Services
    systemctl disable "${NTIOS_SU_ADD_MONITOR_TIMER}"
    systemctl disable "${NTIOS_SU_ADD_MONITOR_SERVICE}"

    #Stop Services
    systemctl stop "${NTIOS_SU_ADD_MONITOR_TIMER}"
    systemctl stop "${NTIOS_SU_ADD_MONITOR_SERVICE}"
}



#---MAIN SUBROUTINE
main() {
    #Define variables
    local pid_isfound="${EMPTYSTRING}"
    local pid=0

    #Check if '/etc/sudoers' exists
    if [[ ! -f "${ETC_SUDOERS_FPATH}" ]]; then
        #Restore file
        Sudoers_Restore

        #Stop Service-Timer
        Services_DisableStop

        return 0;
    fi

    #Get 'pid' which is stored in '/etc/sudoers'
    pid=$(grep "${PATTERN_HASH_PID_COLON}" ${ETC_SUDOERS_FPATH} | grep -o "${PATTERN_HASH_PID_COLON}.*" | cut -d":" -f2)

    #Check the status of 'pid'
    pid_isfound=$(ps axf | grep "${pid}" | grep -v "${PATTERN_GREP}")
    if [[ -z "${pid_isfound}" ]]; then  #pid is dead
        #Restore file
        Sudoers_Restore

        #Stop Service-Timer
        Services_DisableStop
    fi
}



#---EXECUTE MAIN
main
