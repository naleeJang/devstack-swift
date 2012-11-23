#!/usr/bin/env bash

# **client-env.sh**

# Test OpenStack client enviroment variable handling

echo "*********************************************************************"
echo "Begin DevStack Exercise: $0"
echo "*********************************************************************"


# Settings
# ========

# Keep track of the current directory
EXERCISE_DIR=$(cd $(dirname "$0") && pwd)
TOP_DIR=$(cd $EXERCISE_DIR/..; pwd)

# Import common functions
source $TOP_DIR/functions

# Import configuration
source $TOP_DIR/openrc

# Import exercise configuration
source $TOP_DIR/exerciserc

# Unset all of the known NOVA_* vars
unset NOVA_API_KEY
unset NOVA_ENDPOINT_NAME
unset NOVA_PASSWORD
unset NOVA_PROJECT_ID
unset NOVA_REGION_NAME
unset NOVA_URL
unset NOVA_USERNAME
unset NOVA_VERSION

for i in OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL; do
    is_set $i
    if [[ $? -ne 0 ]]; then
        echo "$i expected to be set"
        ABORT=1
    fi
done
if [[ -n "$ABORT" ]]; then
    exit 1
fi

# Set global return
RETURN=0

# Keystone client
# ---------------
if [[ "$ENABLED_SERVICES" =~ "key" ]]; then
    if [[ "$SKIP_EXERCISES" =~ "key" ]] ; then
        STATUS_KEYSTONE="Skipped"
    else
        echo -e "\nTest Keystone"
        if keystone catalog --service identity; then
            STATUS_KEYSTONE="Succeeded"
        else
            STATUS_KEYSTONE="Failed"
            RETURN=1
        fi
    fi
fi

# Swift client
# ------------

if [[ "$ENABLED_SERVICES" =~ "swift" ]]; then
    if [[ "$SKIP_EXERCISES" =~ "swift" ]] ; then
        STATUS_SWIFT="Skipped"
    else
        echo -e "\nTest Swift"
        if swift stat; then
            STATUS_SWIFT="Succeeded"
        else
            STATUS_SWIFT="Failed"
            RETURN=1
        fi
    fi
fi

# Results
# -------

function report() {
    if [[ -n "$2" ]]; then
        echo "$1: $2"
    fi
}

echo -e "\n"
report "Keystone" $STATUS_KEYSTONE
report "Swift" $STATUS_SWIFT

if (( $RETURN == 0 )); then
    echo "*********************************************************************"
    echo "SUCCESS: End DevStack Exercise: $0"
    echo "*********************************************************************"
fi

exit $RETURN
