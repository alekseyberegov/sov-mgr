#!/bin/bash

#################################################
#
#     Tunnel database connections to RedShift
#
#################################################

# Setup config variiables
local_port="4444"
database_host="redshift.prod.clicktripz.com"
database_port="5439"
ssh_login="aleksey@dev.clicktripz.com"

# Start the tunnel
ssh -i ~/.ssh/id_rsa -L ${local_port}:${database_host}:${database_port} ${ssh_login}

