#!/bin/bash
set -e

# Process arguments
while [ 1 ]; do 
    case $1 in
      "--uid")
          shift
          HOST_UID="$1"
          shift
          ;;
      "--user")
          shift
          HOST_USER="$1"
          shift
          ;;
      "--gid")
          shift
          HOST_GID="$1"
          shift
          ;;
      "--group")
          shift
          HOST_GROUP="$1"
          shift
          ;;
      "--version")
          shift
          VERSION="$1"
          shift
          ;;
      "--install")
          shift
          INSTALL="YES"
          ;;
      "--root")
          shift
          ROOT_LOGIN="YES"
          ;;
      "--create-user")
          shift
          CREATE_USER="YES"
          ;;
      "--init-workspace")
          shift
          INIT_WORKSPACE="YES"
          ;;
      *)
          break
          ;;
    esac
done

# protects xilinx settings file from our shell arguments
function apply_xilinx_settings {
    set +e
    . /opt/Xilinx/${VERSION}/ISE_DS/settings$(arch | sed s/x86_64/64/ | sed s/i386/32/).sh
    set -e
}

if [[ -n $CREATE_USER ]]; then
    groupadd --gid "${HOST_GID}" "${HOST_GROUP}"
    useradd  --gid "${HOST_GID}" --uid "${HOST_UID}" --home-dir /home/workspace --no-create-home  "${HOST_USER}"
fi

if [[ -n $INIT_WORKSPACE ]]; then
    echo "initializing workspace"
    chown "${HOST_UID}:${HOST_GID}" /home/workspace
    cp -R /etc/skel /tmp/skel
    chown -R "${HOST_UID}:${HOST_GID}" /tmp/skel
    cp -pR /tmp/skel/. /home/workspace/
    rm -rf /tmp/skel
fi

if [[ -n $INSTALL ]]; then
    export PATH="$PATH:/media/install"
else
    apply_xilinx_settings;
fi

if [[ $# == 0 ]]; then
    set -- "/bin/bash"
fi

if [[ -n $ROOT_LOGIN ]]; then
    exec "$@"
else
    exec gosu "${HOST_USER}" "$@"
fi
