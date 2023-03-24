#!/bin/bash
date
echo "lauching script"
julia --project=. --threads 1 my-analysis.jl &> "stdout/my-analysis.out"
wait
echo "computation over"
date