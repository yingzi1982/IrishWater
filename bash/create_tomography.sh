#!/bin/bash

./create_mesh_coordinates.sh

./octave.sh generate_tomography.m
