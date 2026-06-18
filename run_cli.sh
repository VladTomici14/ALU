#!/bin/bash
# Interactive command-line front-end for the 8-bit ALU (alu_8bit_top).
# Builds the one-shot tb_alu_cli simulation once, then re-runs it for
# every query the user enters, translating the friendly 1-9 operation
# numbering into the internal 4-bit ALU_Sel code.

set -e

BUILD_DIR=build
BIN="$BUILD_DIR/tb_alu_cli.out"

# Make sure the simulation binary exists and is up to date.
make -s "$BIN"

declare -A OP_NAMES=(
    [1]="Addition"
    [2]="Subtraction"
    [3]="Multiplication"
    [4]="Division"
    [5]="AND"
    [6]="OR"
    [7]="XOR"
    [8]="Left Shift"
    [9]="Right Shift"
)

echo ""
echo "=== 8-bit ALU Interactive CLI ==="
echo "Operations: 1=Add  2=Sub  3=Mult  4=Div  5=AND  6=OR  7=XOR  8=LShift  9=RShift"
echo "A and B are entered as unsigned 0-255 (for negatives, use the two's complement value, e.g. -1 = 255)."
echo "Note: Multiplication (3) interprets A and B as signed two's-complement; Result is still the truncated low byte."
echo "Type 'q' at any prompt to quit."
echo ""

while true; do
    read -rp "A (0-255) [q to quit]: " a_in
    [[ "$a_in" == "q" || "$a_in" == "quit" ]] && break

    read -rp "B (0-255) [q to quit]: " b_in
    [[ "$b_in" == "q" || "$b_in" == "quit" ]] && break

    read -rp "Operation (1-9) [q to quit]: " op_in
    [[ "$op_in" == "q" || "$op_in" == "quit" ]] && break

    if ! [[ "$a_in" =~ ^[0-9]+$ ]] || (( a_in > 255 )); then
        echo "  -> A must be an integer between 0 and 255."
        echo ""
        continue
    fi
    if ! [[ "$b_in" =~ ^[0-9]+$ ]] || (( b_in > 255 )); then
        echo "  -> B must be an integer between 0 and 255."
        echo ""
        continue
    fi
    if ! [[ "$op_in" =~ ^[0-9]+$ ]] || (( op_in < 1 || op_in > 9 )); then
        echo "  -> Operation must be an integer between 1 and 9."
        echo ""
        continue
    fi

    alu_sel=$(( op_in - 1 ))
    op_name=${OP_NAMES[$op_in]}

    line=$(vvp "$BIN" "+A=$a_in" "+B=$b_in" "+OP=$alu_sel" | grep '^RESULT=')

    result=$(grep -oP 'RESULT=\K-?[0-9]+' <<< "$line")
    signed=$(grep -oP 'SIGNED=\K-?[0-9]+' <<< "$line")
    z=$(grep -oP 'Z=\K[0-9]+' <<< "$line")
    n=$(grep -oP 'N=\K[0-9]+' <<< "$line")
    v=$(grep -oP 'V=\K[0-9]+' <<< "$line")

    echo ""
    echo "  $op_name: A=$a_in  B=$b_in  ->  Result=$result (signed: $signed)   Z=$z  N=$n  V=$v"
    echo ""
done

echo "Goodbye."