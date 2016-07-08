#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module add jdk/${JAVA_VERSION}
echo "running junit"
ant junit

echo "running tests"
ant run_tests_all

echo "running release"
ant release

echo "building jar"
ant exejar

echo "checking our test case"
# http://www.cs.waikato.ac.nz/~remco/weka_bn/node13.html

echo "bulding module"
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       WEKA_VERSION       $VERSION
setenv       WEKA_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path CLASSPATH         $::env(WEKA_DIR)
prepend-path PATH
MODULE_FILE
) > modules/$VERSION

mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/$VERSION ${LIBRARIES_MODULES}/${NAME}
