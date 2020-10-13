#!/bin/bash
#---Define Constants
CBLOCK_SIZE=512 #in KB
cMBYTES_MAX=1024    #in MB

#---Define variables
hdisk_rw_test_output_filename="hdisk_rw_test.output"
hdisk_rw_test_write_filename="hdisk_rw_test_write.log"
hdisk_rw_test_read_filename="hdisk_rw_test_read.log"
media_dir=/media
hdisk_rw_test_write_log_fpath=${media_dir}/${hdisk_rw_test_write_filename}
hdisk_rw_test_read_log_fpath=${media_dir}/${hdisk_rw_test_read_filename}

block_size="${CBLOCK_SIZE}k"


#---Local functions
GOTO__sub() {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
}

function calc_sum__func() {
    value_A=${1}
    value_B=${2}

    sum=`awk -v A="${value_A}" -v B="${value_B}" 'BEGIN {print (A + B); exit 0}'`

    echo ${sum}
}

function calc_average_msec_perMB__func() {
    value_A=${1}
    multiplier=${2}
    divider=${3}

    average=`awk -v A="${value_A}" -v B="${multiplier}" -v C="${divider}" "BEGIN {print ( (A*B) / C); exit 0}"`

    echo ${average}
}

moveup_and_delete_one_line__sub() {
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
}

main_menu__next__moveup_and_delete_lines__sub() {
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line    
}

error_message__moveup_and_delete_lines__sub() {
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line    
}

numberofmbytes__back__moveup_and_delete_lines__sub() {
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
}

numberofmbytes__next__moveup_and_delete_lines__sub() {
    numberofmbytes__back__moveup_and_delete_lines__sub
}

numberoftest__back__moveup_and_delete_lines__sub() {
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
    tput cuu1   #move-UP one line
    tput el #delete until the end of line
}

numberoftest__next__moveup_and_delete_lines__sub() {
    numberoftest__back__moveup_and_delete_lines__sub
}



#---Start
GOTO__sub INIT



@INIT:
    #---Initial values
    input=""
    input_accum=""

    #Goto next-phase
    GOTO__sub HEADER



@HEADER:
    clear   #clear screen (=basically move done 1 page)
    echo "------------------------------------"
    echo -e "\tREAD & WRITE TEST TOOL"
    echo "------------------------------------"

    #Goto next-phase
    GOTO__sub MAIN_MENU



@MAIN_MENU:
    subdirs_line=`ls -d ${media_dir}/*`
    eval "subdirs_arr=(${subdirs_line})"

    echo -e "Following disk are mounted under: ${media_dir}"
    if [[ -z ${subdirs_arr} ]]; then
        echo -e "\r"
        echo -e "***No mounted disk found"
        echo -e "\r"
        echo -e "***Please connect a USB/SD drive"
        echo -e "\r"

        #Goto next-phase
        GOTO__sub EXIT
    else
        listnum=1   #start with list number 1
        for subdir in "${subdirs_arr[@]}"
        do 
            if [[ -d ${subdir} ]]; then
                echo -e " ${listnum}: ${subdir}"

                listnum=$((listnum+1))
            fi
        done
    fi
    echo -e "\r"
    echo "------------------------------------"
    echo -e "q. Quit"
    echo "------------------------------------"
    echo -e "\r"	


    while true
    do
        #Select an option
        read -N 1 -e -p "Choose an option: " mychoice

        #Only continue if a valid option is selected
        if [[ "${mychoice}" =~ [1-2] ]]; then
            listnum=1
            for subdir in "${subdirs_arr[@]}"
            do 
                if [[ -d ${subdir} ]]; then
                    if [[ ${mychoice} == ${listnum} ]]; then
                        chosen_disk=${subdir}   #update variable with chosen value

                        #Move-up x-number of lines
                        #...And for each line, delete until the end of line
                        main_menu__next__moveup_and_delete_lines__sub

                        #Goto next-phase
                        GOTO__sub NUMBER_OF_MBYTES
                    fi

                    listnum=$((listnum+1))
                fi
            done
        elif [[ "${mychoice}" == "q" ]] || [[ "${mychoice}" == "Q" ]]; then
            echo -e "\r"	
            
            GOTO__sub EXIT
        else    #ENTER was pressed
            #Move-up one line and delete until the end of line
            moveup_and_delete_one_line__sub
        fi
    done



@NUMBER_OF_MBYTES:
    #Set a start value for 'alloc_freediskspace_MAX'
    alloc_freediskspace_MAX=${cMBYTES_MAX}

    #Determine how many bytes to use of WRITE/READ Test
    available_diskspace_KB=`df -T "${chosen_disk}"  | awk 'NR==2{print $5}'`
    available_diskspace_MB=$((available_diskspace_KB/1024))
    available_diskspace_MB_80perc=$(((available_diskspace_MB*80)/100))  #use 80% of the freediskspace

    #'alloc_freediskspace_MAX' is not allowed to exceed 50% of the available freediskspace
    if [[ ${alloc_freediskspace_MAX} -gt ${available_diskspace_MB_80perc} ]]; then
        alloc_freediskspace_MAX=${available_diskspace_MB_80perc}
    fi

    #Half of 'alloc_freediskspace_MAX'
    alloc_freediskspace_halfOf_MAX=$((alloc_freediskspace_MAX/2))

    #Show options
    echo "Allocate free-disk-space for testing (in MB):"
    echo " 1. ${alloc_freediskspace_halfOf_MAX}"
    echo " 2. ${alloc_freediskspace_MAX}"
    echo " m. manual input"
    echo -e "\r"
    echo "------------------------------------"
    echo -e "b. Back"
    echo -e "q. Quit"
    echo "------------------------------------"
    echo -e "\r"	  

    while true
    do
        #Select an option
        read -N 1 -e -p "Choose an option: " mychoice

        #Only continue if a valid option is selected
        if [[ "${mychoice}" =~ [1,2,m] ]]; then   #'mychoice' can only accept the values 1,2,3
            if [[ "${mychoice}" == "1" ]]; then   #'mychoice=1
                alloc_freediskspace=${alloc_freediskspace_halfOf_MAX}

                break   #exit while-loop
            elif [[ "${mychoice}" == "2" ]]; then   #'mychoice=2
                alloc_freediskspace=${alloc_freediskspace_MAX}

                break   #exit while-loop
            else    #mychoice=m
                while true
                do
                    #Move-up one line and delete until the end of line
                    moveup_and_delete_one_line__sub
                    
                    read -e -p "Your allocated free-disk-space in MB (max. ${alloc_freediskspace_MAX}): " manual_input

                    if [[ ! -z ${manual_input} ]]; then
                        if [[ ${manual_input} == ?(-)+([0-9]) ]]; then
                            if [[ ${manual_input} -le ${alloc_freediskspace_MAX} ]]; then
                                alloc_freediskspace=${manual_input}
                            
                                break   #exit while-loop
                            else
                                #Show error message
                                echo -e "\r"
                                echo "***ERROR: maximum allowed allocated free-disk-space EXCEEDED!!! (${manual_input} MB > ${alloc_freediskspace_MAX} MB)"
                                echo -e "\r"

                                sleep 2 #wait for 2 seconds

                                #Move-up x-number of lines
                                #...And for each line, delete until the end of line
                                error_message__moveup_and_delete_lines__sub
                            fi
                        elif [[ "${manual_input}" == "b" ]] || [[ "${manual_input}" == "B" ]]; then
                            #Move-up x-number of lines
                            #...And for each line, delete until the end of line
                            numberofmbytes__back__moveup_and_delete_lines__sub

                            #Goto next-phase
                            GOTO__sub MAIN_MENU
                        else
                            #Show error message
                            echo -e "\r"
                            echo -e "***ERROR: NOT a numerical value '${manual_input}'"
                            echo -e "\r"

                            sleep 2 #wait for 2 seconds
                        
                            #Move-up x-number of lines
                            #...And for each line, delete until the end of line
                            error_message__moveup_and_delete_lines__sub                     
                        fi      
                    fi      
                done

                break   #exit while-loop
            fi
        elif [[ "${mychoice}" == "b" ]] || [[ "${mychoice}" == "B" ]]; then
            #Move-up x-number of lines
            #...And for each line, delete until the end of line
            numberofmbytes__back__moveup_and_delete_lines__sub

            #Goto next-phase
            GOTO__sub MAIN_MENU
            
        elif [[ "${mychoice}" == "q" ]] || [[ "${mychoice}" == "Q" ]]; then
            GOTO__sub EXIT
        else    #ENTER was pressed
            #Move-up one line and delete until the end of line
            moveup_and_delete_one_line__sub
        fi
    done


    #'alloc_freediskspace' is a valid numerical value within the maximum allowed value 'alloc_freediskspace_MAX'
    #Move-up x-number of lines
    #...And for each line, delete until the end of line
    numberofmbytes__next__moveup_and_delete_lines__sub    
    
    #Goto next-phase
    GOTO__sub NUMBER_OF_TESTS



@NUMBER_OF_TESTS:
    #Show options
    echo "Number of times to run this test:"
    echo " 1. 1"
    echo " 2. 2"
    echo " 3. 3"
    echo " m. manual input"
    echo -e "\r"
    echo "------------------------------------"
    echo -e "b. Back"
    echo -e "h. Main menu"
    echo -e "q. Quit"
    echo "------------------------------------"
    echo -e "\r"	  

    while true
    do
        #Select an option
        read -N 1 -e -p "Choose an option: " mychoice

        #Only continue if a valid option is selected
        if [[ "${mychoice}" =~ [1,2,3,m] ]]; then   #'mychoice' can only accept the values 1,2,3
            if [[ "${mychoice}" == "1" ]]; then   #'mychoice=1
                numOf_tests__max=1

                break   #exit while-loop
            elif [[ "${mychoice}" == "2" ]]; then   #'mychoice=2
                numOf_tests__max=2

                break   #exit while-loop
            elif [[ "${mychoice}" == "3" ]]; then   #'mychoice=3
                numOf_tests__max=3

                break   #exit while-loop
            else    #mychoice=m
                while true
                do
                    #Move-up one line and delete until the end of line
                    moveup_and_delete_one_line__sub
                    
                    read -e -p "Your input of number of tests: " manual_input

                    if [[ ! -z ${manual_input} ]]; then
                        if [[ ${manual_input} == ?(-)+([0-9]) ]]; then
                            numOf_tests__max=${manual_input}

                            break   #exit while-loop
                        elif [[ "${mychoice}" == "b" ]] || [[ "${mychoice}" == "B" ]]; then
                            #Move-up x-number of lines
                            #...And for each line, delete until the end of line
                            numberoftest__back__moveup_and_delete_lines__sub

                            #Goto next-phase
                            GOTO__sub NUMBER_OF_MBYTES

                        elif [[ "${mychoice}" == "h" ]] || [[ "${mychoice}" == "H" ]]; then
                            #Move-up x-number of lines
                            #...And for each line, delete until the end of line
                            numberoftest__back__moveup_and_delete_lines__sub

                            #Goto next-phase
                            GOTO__sub MAIN_MENU
                        else
                            #Show error message
                            echo -e "\r"
                            echo -e "***ERROR: NOT a numerical value '${manual_input}'"
                            echo -e "\r"

                            sleep 2 #wait for 2 seconds
                        
                            #Move-up x-number of lines
                            #...And for each line, delete until the end of line
                            error_message__moveup_and_delete_lines__sub                     
                        fi      
                    fi      
                done

                break   #exit while-loop
            fi
        elif [[ "${mychoice}" == "b" ]] || [[ "${mychoice}" == "B" ]]; then
            #Move-up x-number of lines
            #...And for each line, delete until the end of line
            numberoftest__back__moveup_and_delete_lines__sub

            #Goto next-phase
            GOTO__sub NUMBER_OF_MBYTES

        elif [[ "${mychoice}" == "h" ]] || [[ "${mychoice}" == "H" ]]; then
            #Move-up x-number of lines
            #...And for each line, delete until the end of line
            numberoftest__back__moveup_and_delete_lines__sub

            #Goto next-phase
            GOTO__sub MAIN_MENU
            
        elif [[ "${mychoice}" == "q" ]] || [[ "${mychoice}" == "Q" ]]; then
            GOTO__sub EXIT
        else    #ENTER was pressed
            #Move-up one line and delete until the end of line
            moveup_and_delete_one_line__sub
        fi
    done



@START_TEST:
    #Start Test(s)
    alloc_freediskspace_min=$((alloc_freediskspace/2))   #minimum alloc_freediskspace (50% of 'alloc_freediskspace')
    alloc_freediskspace_diff=$((alloc_freediskspace-alloc_freediskspace_min))   #random value will be taken between 0 and 'alloc_freediskspace_diff'

    echo "***************************************************************"
    echo -e "\tSTART WRITE & READ TESTS"
    echo "***************************************************************"
    echo -e "\tTARGET MEDIA:\t\t\t${chosen_disk}"
    echo -e "\tALLOCATED DISK SPACE (in MB):\t${alloc_freediskspace_min} - ${alloc_freediskspace}"
    echo -e "\tNUMBER OF TESTS: \t\t${numOf_tests__max}"
    echo "***************************************************************"

    numOf_tests__counter=1
    write_error=0
    write_success=0
    read_error=0
    read_success=0
    write_latency_time_msec_per_MB__total=0
    read_latency_time_msec_per_MB__total=0
    multiplier_sec2msec=1000
    while true
    do
        #First: RANDOM % ${alloc_freediskspace_diff}: generate a random value between 0 and 'alloc_freediskspace_diff'
        #Then: ( RANDOM % ${alloc_freediskspace_diff} ) + ${alloc_freediskspace_min}: accumulate with 'alloc_freediskspace_min'
        alloc_freediskspace=$(( ( RANDOM % ${alloc_freediskspace_diff} ) + ${alloc_freediskspace_min} ))
        #First: alloc_freediskspace*1024: convert from MB to KB
        #Then: (alloc_freediskspace*1024)/CBLOCK_SIZE: divide by 512KB
        alloc_count=$(((alloc_freediskspace*1024)/CBLOCK_SIZE))


        echo -e "\r"
        echo -e "START WRITING (${alloc_freediskspace} MB of DATA) #${numOf_tests__counter}..."
            sudo sh -c "dd if=/dev/zero of=${chosen_disk}/${hdisk_rw_test_output_filename} bs=${block_size} count=${alloc_count} oflag=dsync status=progress 2>&1 | tee -a ${hdisk_rw_test_write_log_fpath}"

            write_records_in=`sudo sh -c "cat ${hdisk_rw_test_write_log_fpath} | egrep 'records in' | cut -d' ' -f1"`
            write_records_out=`sudo sh -c "cat ${hdisk_rw_test_write_log_fpath} | egrep 'records out' | cut -d' ' -f1"`

            if [[ ${write_records_in} != ${write_records_out} ]]; then
                echo -e "WARNING: COMPLETED WRITING #${numOf_tests__counter} WITH ERROR!!!"

                write_error=$((write_error+1))
            else
                echo -e "COMPLETED WRITING #${numOf_tests__counter} SUCCESSFULLY"

                write_latency_time=`sudo sh -c "cat ${hdisk_rw_test_write_log_fpath} | egrep 'copied' | cut -d',' -f3 | cut -d' ' -f2"`
                write_latency_time_msec_per_MB=`calc_average_msec_perMB__func "${write_latency_time}" "${multiplier_sec2msec}" "${alloc_freediskspace}"`
                write_latency_time_msec_per_MB__total=`calc_sum__func "${write_latency_time_msec_per_MB__total}" "${write_latency_time_msec_per_MB}"`

                write_success=$((write_success+1))
            fi
        echo -e "\r"  

        echo -e "\r"
        echo -e "START READING (${alloc_freediskspace} MB of DATA) #${numOf_tests__counter}..."
            sudo sh -c "dd if=${chosen_disk}/${hdisk_rw_test_output_filename} of=/dev/null bs=${block_size} count=${alloc_count} oflag=dsync status=progress 2>&1 | tee -a ${hdisk_rw_test_read_log_fpath}"
        
            read_records_in=`sudo sh -c "cat ${hdisk_rw_test_read_log_fpath} | egrep 'records in' | cut -d' ' -f1"`
            read_records_out=`sudo sh -c "cat ${hdisk_rw_test_read_log_fpath} | egrep 'records out' | cut -d' ' -f1"`

            if [[ ${read_records_in} != ${read_records_out} ]]; then
                echo -e "WARNING: COMPLETED READING #${numOf_tests__counter} WITH ERROR!!!"

                read_error=$((read_error+1))
            else
                echo -e "COMPLETED READING #${numOf_tests__counter} SUCCESSFULLY"
                
                read_latency_time=`sudo sh -c "cat ${hdisk_rw_test_read_log_fpath} | egrep 'copied' | cut -d',' -f3 | cut -d' ' -f2"`
                read_latency_time_msec_per_MB=`calc_average_msec_perMB__func "${read_latency_time}" "${multiplier_sec2msec}" "${alloc_freediskspace}"`
                read_latency_time_msec_per_MB__total=`calc_sum__func "${read_latency_time_msec_per_MB__total}" "${read_latency_time_msec_per_MB}"`

                read_success=$((read_success+1))
            fi
        echo -e "\r"  

        #Removing Temporary files
        if [[ -f ${hdisk_rw_test_write_log_fpath} ]]; then
            sudo sh -c "rm ${hdisk_rw_test_write_log_fpath}"
        fi
        if [[ -f ${hdisk_rw_test_read_log_fpath} ]]; then
            sudo sh -c "rm ${hdisk_rw_test_read_log_fpath}"
        fi

        #Increment numOf_tests__counterer by 1
        numOf_tests__counter=$((numOf_tests__counter + 1))

        if [[ ${numOf_tests__counter} -gt ${numOf_tests__max} ]]; then
            break
        fi
    done


    #Update to-be-displayed data
    numOf_tests__counter=$((numOf_tests__counter-1))

    multiplier_msec2msec=1 
    #'write_latency_time_msec_per_MB__total' is already in msec. Therefore, the 'multiplier_msec2msec=1' is used
    write_latency_time__avg=`calc_average_msec_perMB__func "${write_latency_time_msec_per_MB__total}" "${multiplier_msec2msec}" "${write_success}"`
    #'read_latency_time_msec_per_MB__total' is already in msec. Therefore, the 'multiplier_msec2msec=1' is used
    read_latency_time__avg=`calc_average_msec_perMB__func "${read_latency_time_msec_per_MB__total}" "${multiplier_msec2msec}" "${read_success}"`

    #Show information
    echo -e "\r"
    echo "***************************************************************"
    echo -e "\tCOMPLETED ALL TESTS"
    echo "***************************************************************"
    echo -e "\tWRITE SUCCESS: ${write_success} out-of ${numOf_tests__max}"
    echo -e "\tWRITE ERROR: ${write_error} out-of ${numOf_tests__max}"
    echo -e "\tWRITE LATENCY (msec) per MB: ${write_latency_time__avg}"
    echo -e "\r"
    echo -e "\tREAD SUCCESS: ${read_success} out-of ${numOf_tests__max}"
    echo -e "\tREAD ERROR: ${read_error} out-of ${numOf_tests__max}"
    echo -e "\\tREAD LATENCY (msec) per MB: ${read_latency_time__avg}"
    echo "***************************************************************"
    echo -e "\r"

    #Removing temporary files
    echo -e "\r"
    echo -e "Removing temporary file: ${hdisk_rw_test_output_filename}"
    echo -e "\r"
        if [[ -f "${chosen_disk}/${hdisk_rw_test_output_filename}" ]]; then
            sudo sh -c "rm ${chosen_disk}/${hdisk_rw_test_output_filename}"
        fi

    #Goto next-phase
    GOTO__sub EXIT


@EXIT:
    echo -e "\r"
    echo -e "Exiting Now..."
    echo -e "\r"
    echo -e "\r"

    exit
