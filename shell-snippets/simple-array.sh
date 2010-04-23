NAMES=(max helen sam zach)
echo ${NAMES[2]}

A=("${NAMES[*]}")
B=("${NAMES[@]}")

echo ${A[1]}
echo ${A[0]}
echo ${B[1]}
echo ${B[0]}

# Number of elements in the array
# echo ${#NAMES[*]}
# # Length of a specific entity
# echo ${#NAMES[1]}
#
# echo ${NAMES[*]}
# NAMES[1]=alex
# echo ${NAMES[*]}
