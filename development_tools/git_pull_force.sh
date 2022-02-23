#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__FG_ORANGE=$'\e[30;38;5;209m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__TITLE_FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__GIT_FG_WHITE=$'\e[30;38;5;243m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'


#---Define constants
DOCKER__TITLE="TIBBO"


#---Local functions & subroutines
docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__git_pull_force__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "${DOCKER__GENERAL_FG_YELLOW}Git${DOCKER__NOCOLOR} ${DOCKER__FG_ORANGE}PULL${DOCKER__NOCOLOR} ${DOCKER__FG_PURPLERED}FORCE${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        while true
        do
            echo -e "***${DOCKER__FG_PURPLERED}WARNING${DOCKER__NOCOLOR}: ALL local data will be LOST!!!"
            read -N1 -r -s -e -p "Do you wish to ${DOCKER__FG_PURPLERED}FORCE${DOCKER__NOCOLOR} PULL (y/n)? " myChoice
            if [[ ${myChoice} =~ [y,n] ]]; then
                if [[ ${myChoice} == "y" ]]; then
                    git reset --hard HEAD
                    git clean -f -d
                    git pull                   
                fi

                break
            else    #all other cases (e.g. ENTER or any-other-key was pressed)
                tput cuu1
                tput el
                tput cuu1
                tput el
            fi
        done

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}


main_sub() {
    docker__load_header__sub

    docker__git_pull_force__sub
}


#Execute main subroutine
main_sub
