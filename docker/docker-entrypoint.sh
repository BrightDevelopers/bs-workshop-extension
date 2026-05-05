#!/bin/bash
set -e

HOST_UID=${HOST_UID:-1000}
HOST_GID=${HOST_GID:-1000}

# Remap the workshop user's UID/GID to match the host user so that files
# written to bind-mounted volumes have the correct ownership on the host.
if [ "$(id -u)" = "0" ]; then
    if [ "$HOST_GID" != "1000" ]; then
        if ! getent group "$HOST_GID" >/dev/null 2>&1; then
            groupmod -g "$HOST_GID" workshop
        else
            groupdel workshop 2>/dev/null || true
            usermod -g "$HOST_GID" workshop
        fi
    fi
    if [ "$HOST_UID" != "1000" ]; then
        usermod -u "$HOST_UID" workshop
        chown "$HOST_UID:$HOST_GID" /home/workshop 2>/dev/null || true
        for item in .bashrc .profile .bash_logout .bash_history .inputrc .config .cache .local .ssh .gnupg; do
            if [ -e "/home/workshop/$item" ]; then
                chown -R "$HOST_UID:$HOST_GID" "/home/workshop/$item" 2>/dev/null || true
            fi
        done
    fi
    exec gosu workshop "$@"
else
    exec "$@"
fi
