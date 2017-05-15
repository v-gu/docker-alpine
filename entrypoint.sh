#!/usr/bin/env sh

# define process array
proc_comms=()

# start processes
index=1
while /bin/true
do
    v_proc_cmdline="PROC${index}"
    v_proc_comm="PROC${index}_NAME"
    v_proc_bg="PROC${index}_BG"

    # no more process definitions, exit loop
    if [ -n "${!v_proc_cmdline+x}" ]; then break; fi

    proc_cmdline="${!v_proc_cmdline}"
    proc_comm_augs="$(basename ${proc_cmdline})"
    proc_comm_deducted="${proc_cmdline%% *}"
    proc_comm="${!v_proc_comm:-${proc_comm_deducted}}"
    proc_bg="${!v_proc_bg:-true}"

    procs+=("${proc_comm}")

    # test if currently we are on PROC1 and there is no PROC2 definition, exec cmdline directly
    if [ $index -eq 1 -a -z "${PROC2+x}" ]; then
        exec ${proc_cmdline}
    fi

    # start daemon/background process
    proc_real_cmdline="${proc_cmdline}"
    if [ "${proc_bg}" == "true" ]; then
        proc_real_cmdline="${proc_real_cmdline} &"
    fi
    ${proc_real_cmdline}

    # check daemon process exit status
    if [ "${proc_bg}" != "true" ]; then
        status=$?
        if [ $status -ne 0 ]; then
            echo "Failed to start ${proc_cmdline}: ${status}"
            exit $status
        fi
    fi

    index=$((index+1))
done

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container will exit with an error
# if it detects that either of the processes has exited.
# Otherwise it will loop forever, waking up every 60 seconds

while /bin/true; do
    length=${#proc_comms[@]}
    for i in $(seq 0 $((length-1))); do
        status=$(ps aux |grep -q "${proc_comms[$i]}" |grep -v grep)
        # If the greps above find anything, they will exit with 0 status
        # If they are not both 0, then something is wrong
        if [ $status -ne 0 ]; then
            echo "${proc_comms[$i]} has already exited."
            exit -1
        fi
    done
  sleep 60
done
