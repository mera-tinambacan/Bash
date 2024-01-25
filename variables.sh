# -- A simple variable example

#!/bin/bash
 
 greeting="Good morning"
 name="Mera"

 echo "$greeting, $name"

## Result: Good morning, Mera

# -- Assigning variables thru user input --

#!/bin/bash

echo "Enter two numbers:"
read -p "Number 1: " num1
read -p "Number 2: " num2

echo "The sum of $num1 and $num2 is $(($num1 + $num2))"

# Result: the sum of num1 and num2 is numm1+num2
