#!/bin/bash

# If unzip is not installed yet, install it using one of the following lines:
#     sudo apt-get install unzip
#     sudo yum install unzip

# If gcc and gfortran are not installed yet, install them using one of the following lines:
#     sudo apt-get install gfortran
#     sudo yum install gcc-gfortran


unzip source_codes.zip
cd source_codes

####################################
## STEP a : compile fortran codes ##
####################################

splines="splines.f"
make_sparse_geometry="make_sparse_geometry.f"
make_sparse_geometry_for_cyclic_x="make_sparse_geometry_for_cyclic_x.f"
prepare_finer_sparse_grid="prepare_finer_sparse_grid.f"

for i in *.f; do
output="${i%.*}"

echo -------------------------------
if [ "$i" == "$splines" ]; then
    echo "$i" ": This file is a subroutine used by other *.f files. Pass."
    continue
elif [ "$i" == "$make_sparse_geometry" ]; then
    echo "$i" "-> make_sparse_geometry"
    gfortran "$i" splines.f -o make_sparse_geometry -ffixed-line-length-none 
elif [ "$i" == "$make_sparse_geometry_for_cyclic_x" ]; then
    echo "$i" "-> make_sparse_geometry_for_cyclic_x"
    gfortran "$i" splines.f -o make_sparse_geometry_for_cyclic_x -ffixed-line-length-none
elif [ "$i" == "$prepare_finer_sparse_grid" ]; then
    echo "$i" "-> prepare_finer_sparse_grid"
    gfortran "$i" splines.f -o prepare_finer_sparse_grid -ffixed-line-length-none 
else
    echo "$i" "->" "$output"
    gfortran "$i" -o "$output" -ffixed-line-length-none -fdec-math -std=legacy
fi
done


#-ffixed-line-length-none : Ignore column lengths
#-fdec-math : For dcosd, cosd, etc
#-Wno-Wargument-mismatch : turn off mismatch warnings



####################################
## STEP b : compile   *.c   codes ##
####################################
echo -------------------------------
for j in *.c; do
output="${j%.*}"

echo -------------------------------
echo "$j" "->" "$output"
gcc "$j" -o "$output" -lm
done

echo -------------------------------
echo -------------DONE--------------
echo -------------------------------


#Set $PATH automatically if one of the files already exist.
 
bashprofile=~/.bash_profile
bashrc=~/.bashrc
zshrc=~/.zshrc

if test -f "$bashprofile"; then
    echo "Setting PATH permanently in the existing file ~/.bash_profile"
    sudo echo $"export PATH=\$PATH:$(pwd)" >> ~/.bash_profile
    sudo source ~/.bash_profile
elif test -f "$bashrc"; then
    echo "Setting PATH permanently in the existing file ~/.bashrc"
    sudo echo $"export PATH=\$PATH:$(pwd)" >> ~/.bashrc
    sudo source ~/.bashrc
elif test -f "$zshrc"; then
    echo "Setting PATH permanently in the existing file ~/.zshrc"
    sudo echo $"export PATH=\$PATH:$(pwd)" >> ~/.zshrc
    sudo source ~/.zshrc
else
    dir=`pwd`
    echo ~/.bashrc, ~/.bash_profile, or ~/.zshrc exist. 
    echo Creating ~/.bashrc and setting PATH permanently in the created file
    sudo echo $"export PATH=\$PATH:$(pwd)" > ~/.bashrc
    sudo source ~/.bashrc
fi
