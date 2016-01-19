# test frontend code (simulated)
# launched like `/bin/bash pipeline-lock.sh` in jenkins shell task
# herein is testing code, meant to contain enough detail to seem
# realistic and helpful for devising your own solution

# demo-related magic number
SIMULATED_SECONDS_BUSY=$1

# load library functions via source
script_path=$(dirname $0)
. $script_path/functions.sh

# when using scripts with jenkins, define directories as env
# variables, which allows you to change directory from the
# value "tooling" to "/opt/kanban_bash/tooling" via config
# then you will be using working directory, and not jenkins
# workspace -- but then, you may need to adjust the current
# directory to simulate being in the workspace
if [[ $script_path == /opt* ]]
then
    cd $script_path
    cd ..
fi

# setup and announce stage
pipeline_log_stage "007-test-frontend"

# browserstack is an external service for browser testing
# we may run two browserstack sessions concurrently, but have
# set jenkins to run five jobs at once, hence we need to either
# endure possible issues, or manage capacity
pipeline_log_action "request browserstack lock"

# WARNING: be wary of using default ("0") database for any other
# testing process (as you may flushdb and interfere with locks)
lock_aquired=""
BROSWERSTACK_KANBAN_01="bs-kanban-01"
BROSWERSTACK_KANBAN_02="bs-kanban-02"

# assign timeouts
# not so realistic, make demo faster
WAIT_CYCLE=20
test_timeout=120  # two minutes
lock_timeout=$(( test_timeout + WAIT_CYCLE ))
wait_timeout=$(( test_timeout + (3 * WAIT_CYCLE) ))  # three minutes
ATTEMPT=0
MAX_TRIES=$(( wait_timeout / WAIT_CYCLE ))
while [[ true ]]; do
    # timeout escape
    if [[ $ATTEMPT -eq MAX_TRIES ]]; then
        echo  # add line break after wait
        pipeline_log_info "lock denied (timeout)"
        EXIT_CODE=1
        # post fail to chat application
        # update github commit status
        exit $EXIT_CODE
    fi

    # test lock availability
    if [[ -z $lock_aquired ]]
    then
        value=$(date -u '+%Y%m%d-%H%M')
        result=$(redis-cli set $BROSWERSTACK_KANBAN_01 $value EX $lock_timeout NX)
        if [[ $result == "OK" ]]
        then
            lock_aquired=$BROSWERSTACK_KANBAN_01
        fi
    fi

    if [[ -z $lock_aquired ]]
    then
        value=$(date -u '+%Y%m%d-%H%M')
        result=$(redis-cli set $BROSWERSTACK_KANBAN_02 $value EX $lock_timeout NX)
        if [[ $result == "OK" ]]
        then
            lock_aquired=$BROSWERSTACK_KANBAN_02
        fi
    fi

    # lock aquired escape
    if [[ -n "$lock_aquired" ]]
    then
        if [[ $ATTEMPT -ne 0 ]]
        then
            # add line break after wait
            echo
        fi
        pipeline_log_info "lock aquired"
        break;
    fi

    # wait until next attempt
    if [[ $ATTEMPT -eq 0 ]]
    then
        printf ">>>>>>>>  waiting"
    else
        printf "."
    fi
    ((ATTEMPT++))
    sleep $WAIT_CYCLE
done

# run frontend tests
# pipeline_log_action "testing (frontend) - testem"
# ssh -i $AWS_PRIVATE_KEY $AWS_USER@$PRIVATE_IP_ADDRESS \
#   "cd /opt/kanban_bash/frontend && timeout 7m testem ci"
# EXIT_CODE=$?

# simulated testing
now=$(date -u '+%Y%m%d-%H:%M:%S')
pipeline_log_action "] simulate-testing -- start :: $now"
timeout 2m sleep $SIMULATED_SECONDS_BUSY
now=$(date -u '+%Y%m%d-%H:%M:%S')
pipeline_log_action "] simulate-testing --   end :: $now"

# remove lock
if [[ -n "$lock_aquired" ]]
then
    pipeline_log_action "release browserstack lock"
    result=$(redis-cli DEL $lock_aquired)
fi

# update status on fail
if [[ $EXIT_CODE -ne 0 ]]
then
    pipeline_log_action "update commit status"
    # update github commit status
    if [[ $EXIT_CODE -eq 124 ]]
    then
        # posting alerts to chat goes here
        echo "frontend testing time-out"
    else
        # alas, if only comments here
        # there would be errors
        echo "frontend fail"
    fi
fi

# jenkins will short-circuit job on failure
exit $EXIT_CODE
