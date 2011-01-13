#/bin/bash -x

# George Wood
# 2010 May 05
# Copyright 2010

### TESTED with this script
# cd ~/Documents && rm -rf tmp rep ~/Depot/rep.git
# bash -xv ./setup/git_setup.sh 

# Bash script to automate the construction of git 
# authoritative and development directories
# Initialize a repository

# DOC=~/Documents/Stanford-iPhone/Winter-2010/Depot
SCRIPT_FULL_PATH=`canonicalize $0`
SETUP="$(dirname "$SCRIPT_FULL_PATH")"
LOCAL_DEPOT="$(dirname "$SETUP")"
LOCAL_DEPOT_BASE="$(basename "$LOCAL_DEPOT")"
echo LOCAL_DEPOT=$LOCAL_DEPOT LOCAL_DEPOT_BASE=$LOCAL_DEPOT_BASE
if [ "$LOCAL_DEPOT_BASE" != "Depot" ] 
then
    echo "Did not find Depot in directory above setup"
    exit
# else
#     echo "Depot was grandparent"
fi



ARGCOUNT=1
E_WRONGARGS=65

TMP=${LOCAL_DEPOT}/tmp
# Ensure that we have one argument...

if [ $# -ne $ARGCOUNT ]
then
   echo "Usage: `basename $0` repository"
   exit $E_WRONGARGS
fi

REP=$1
mkdir -p ${TMP}                                                 || exit 1
cd ${TMP}                                                       || exit 1
mkdir ${REP}                                                    || exit 1
cd ${REP}                                                       || exit 1
git init                                                        || exit 1

# Now install the .gitignore and .gitattribures files for XCode development
/bin/cp ${SETUP}/.gitignore  ${SETUP}/.gitattributes .          || exit 1
/bin/cp ${SETUP}/git_setup.sh .                                 || exit 1
git add .gitignore .gitattributes  git_setup.sh                 || exit 1
git commit -a -m "Added git XCode specific configuration files" || exit 1

# Build an autoritative repository from the first repository. D=~/Depot
GLOBAL_DEPOT=~/Depot
mkdir -p ${GLOBAL_DEPOT}                                        || exit 1
cd ${GLOBAL_DEPOT}                                              || exit 1
git clone --bare ${TMP}/${REP} ${REP}.git                       || exit 1
echo Please "rm -irf ${TMP}/${REP} # when done"                 || exit 1

# Now build a clone of the first temporary directory
# which will be the development directory
CLONE=${LOCAL_DEPOT}/${REP}
cd ${LOCAL_DEPOT}                                               || exit 1
# Clone makes the ${REP}/.git directory..
git clone ${GLOBAL_DEPOT}/${REP}                                || exit 1

cd ${CLONE}                                                     || exit 1
git push                                                        || exit 1
# git status -- Has no zero status even when there are no errors...
git status 
git show-branch  --more=10                                      || exit 1
exit 0
