#!/bin/bash

cd /root/src

if [[ $MKDOCS_MODE == "serve" ]]; then
    mkdocs serve
else
    mkdocs build
    chmod 777 -R /root/src
fi 