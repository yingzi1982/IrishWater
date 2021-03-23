#!/bin/bash 

signal_name=$1

./octave.sh filter_signal.m $signal_name
