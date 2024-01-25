#!/bin/bash

echo "Enter two numbers:"
read -p "Number 1: " num1
read -p "Number 2: " num2

echo "Choose an operation:"
echo "1. Addition"
echo "2. Subtraction"
echo "3. Multiplication"
echo "4. Division"

read -p "Enter the operation number (1-4): " operation

case $operation in
  1) result=$(($num1 + $num2)); operation_name="Addition" ;;
  2)
    if [ $num1 -lt $num2 ]; then
      echo "Cannot calculate. Value is negative."
      exit 1
    fi
    result=$(($num1 - $num2))
    operation_name="Subtraction" ;;
  3) result=$(($num1 * $num2)); operation_name="Multiplication" ;;
  4)
    if [ $num2 -eq 0 ]; then
      echo "Error: Division by zero is undefined."
      exit 1
    fi
    result=$(($num1 / $num2))
    operation_name="Division" ;;
  *) echo "Invalid operation number."; exit 1 ;;
esac

echo "$operation_name Result: $result"
