#!/bin/bash -e
. /etc/profile.d/modules.sh

module add ci
module add jdk/${JAVA_VERSION}

IFS='.' read -r -a array <<< "$VERSION"
VERSION_MAJOR=${array[0]}
VERSION_MINOR=${array[1]}
# Way to go, Weka dudes, you can't stick to a naming scheme
YA_VERSION=$(echo $VERSION | sed  s#\\.#-#g)
SOURCE_FILE=${NAME}-${YA_VERSION}.zip

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file

if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - let's geet the source"
#  wget http://tenet.dl.sourceforge.net/project/weka/weka-3-8/3.8.0/weka-3-8-0.zip
  wget http://sourceforge.net/projects/${NAME}/files/${NAME}-${VERSION_MAJOR}-${VERSION_MINOR}/${VERSION}/${SOURCE_FILE}/download -O ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
fi

unzip  -n -u ${SRC_DIR}/${SOURCE_FILE} -d ${WORKSPACE}
ant compile
