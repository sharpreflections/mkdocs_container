#!/bin/bash

cd /workdir/src

if [[ $MKDOCS_MODE == "serve" ]]; then
    mkdocs serve
else
    mkdocs build
fi 
