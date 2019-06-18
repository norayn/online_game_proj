#!/bin/sh
cat protocol.py | sed 's/class / /g' | sed 's/:/ = {/g' | sed 's/\x27\x27\x27end\x27\x27\x27/}/g' | sed 's/##/,--/g' | sed 's/#/--/g' > protocol.lua 
echo 'mimimi' 
