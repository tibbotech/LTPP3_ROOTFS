#!/bin/bash
#---SUBROUTINES
docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__git_pull_force__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "${DOCKER__FG_YELLOW}Git${DOCKER__NOCOLOR} ${DOCKER__FG_ORANGE}PULL${DOCKER__NOCOLOR} ${DOCKER__FG_PURPLERED}FORCE${DOCKER__NOCOLOR}"
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



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__git_pull_force__sub
}


#---EXECUTE
main_sub
