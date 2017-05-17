#!/usr/bin/env bash

if [ "${INIT_DEBUG}" == true ]; then
    env
    set -x
fi

function cleanup {
    echo "got signal, quit now" >&2
}
trap cleanup SIGINT SIGTERM

# define process array
proc_comms=()

# start processes
index=1
while /bin/true
do
    v_proc_cmdline="PROC${index}"
    v_proc_comm="PROC${index}_NAME"
    v_proc_isdaemon="PROC${index}_ISDAEMON"
    v_proc_script_dirname="PROC${index}_SCRIPT_DIRNAME"

    # no more process definitions, exit loop
    if [ -z "${!v_proc_cmdline+x}" ]; then break; fi

    proc_cmdline="${!v_proc_cmdline}"
    proc_comm_augs="$(basename ${proc_cmdline})"
    proc_comm_deducted="${proc_cmdline%% *}"
    proc_comm="${!v_proc_comm:-${proc_comm_deducted}}"
    proc_isdaemon="${!v_proc_isdaemon:-false}"
    proc_script_dirname="${!v_proc_script_dirname:-${proc_comm}}"

    procs+=("${proc_comm}")

    # execute process config script
    pwd="${PWD}"
    proc_script_dir="${PROC_SCRIPTS_DIR}/${proc_script_dirname}"
    proc_script_file="${proc_script_dir}/main.sh"
    if [ -x "${proc_script_file}" ]; then
        echo "found script for app '${proc_comm}' at '${proc_script_file}', load it now ..." >&2
        cd "${proc_script_dir}"
        ${proc_script_dir}/main.sh
        cd "${pwd}"
    fi

    # start daemon/background process
    if [ "${proc_isdaemon}" != "true" ]; then
        # this is a foreground process
        # test if we are currently on PROC1 and there is no PROC2 definition, exec cmdline directly
        if [ $index -eq 1 -a -z "${PROC2+x}" ]; then
            exec ${proc_cmdline}
        else
            # run it in background
            ${proc_cmdline} &
        fi
    else
        # this is a daemon process, simply execute it
        ${proc_cmdline}
    fi

    # check daemon process exit status
    if [ "${proc_isdaemon}" == "true" ]; then
        status=$?
        if [ $status -ne 0 ]; then
            echo "Failed to start ${proc_cmdline}: ${status}" >&2
            exit $status
        fi
    fi

    index=$((index+1))
done

# check total process number
if [ ${#proc_comms[@]} -eq 0 ]; then
    echo "no process started, quit" >&2
    exit 1
fi

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
            echo "${proc_comms[$i]} has already exited." >&2
            exit -1
        fi
    done
  sleep 60
done
