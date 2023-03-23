#!/bin/bash
pathsim=$1
threads=$2
namesim=$(basename ${pathsim})

date
echo "lauching script for $namesim"
$HOME/utils/julia-1.7.2/bin/julia --project=./julia/ --threads $threads "$pathsim.jl" &> "stdout/${namesim}.out"
wait
echo "computation over"
date