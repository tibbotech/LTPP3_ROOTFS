#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
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
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__git_pull__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "${DOCKER__GENERAL_FG_YELLOW}Git${DOCKER__NOCOLOR} ${DOCKER__FG_ORANGE}PULL${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"

        git pull

    echo -e "\r"
    echo -e "\r"
}


main_sub() {
    docker__load_header__sub

    docker__git_pull__sub
}


#Execute main subroutine
main_sub
