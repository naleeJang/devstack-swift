#!/usr/bin/env bash

# **client-args.sh**

# Test OpenStack client authentication aguemnts handling

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

# Save the known variables for later
export x_TENANT_NAME=$OS_TENANT_NAME
export x_USERNAME=$OS_USERNAME
export x_PASSWORD=$OS_PASSWORD
export x_AUTH_URL=$OS_AUTH_URL

# Unset the usual variables to force argument processing
unset OS_TENANT_NAME
unset OS_USERNAME
unset OS_PASSWORD
unset OS_AUTH_URL

# Common authentication args
TENANT_ARG="--os_tenant_name=$x_TENANT_NAME"
TENANT_ARG_DASH="--os-tenant-name=$x_TENANT_NAME"
ARGS="--os_username=$x_USERNAME --os_password=$x_PASSWORD --os_auth_url=$x_AUTH_URL"
ARGS_DASH="--os-username=$x_USERNAME --os-password=$x_PASSWORD --os-auth-url=$x_AUTH_URL"

# Set global return
RETURN=0

# Keystone client
# ---------------
if [[ "$ENABLED_SERVICES" =~ "key" ]]; then
    if [[ "$SKIP_EXERCISES" =~ "key" ]] ; then
        STATUS_KEYSTONE="Skipped"
    else
        echo -e "\nTest Keystone"
        if keystone $TENANT_ARG $ARGS catalog --service identity; then
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
        if swift $TENANT_ARG $ARGS stat; then
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
