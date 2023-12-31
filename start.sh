#!/bin/bash

# Start NGINX in the background
nginx &

# Starts OpenVSCode Server
exec ${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server --host 0.0.0.0 --without-connection-token "$@"
