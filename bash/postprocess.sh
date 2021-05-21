#!/bin/bash

./backup_data.sh
./process_data.sh
exit

./create_hydrophone_signal.sh

./create_specfem_signal.sh

./gmt.sh
