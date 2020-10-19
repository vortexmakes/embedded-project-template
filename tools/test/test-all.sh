#!/bin/bash -e
#
# Usage:
#   From a Ceedling container: 
#   sudo docker run --rm -v local/path/to/Project/:/usr/project -ti leanfrancucci/ceedling
#   cd tools/ceedling
#   ./test-all.sh
#

source_dir="../../src"
ceedling_dir="tools/test"
modules="ModuleA"
stateMachines=""
exceptionModules=""

export PATH="$PATH:/home/travis/.rvm/gems/ruby-2.4.1/bin"

if [ ! -d $source_dir ]; then
    echo "[ERROR] This script must be invoked from "$ceedling_dir
    exit 1
fi

repeat()
{
    printf "%$2s" |tr " " "$1"
}

title()
{
    echo ""
    msg=$1
    echo $msg
    repeat "=" ${#msg}
    echo ""
}

cleanModules()
{
    for sm in $stateMachines;
    do
        title "Clean "$sm "state machine"
        cd $source_dir/$sm
         if [[ ! -e project.yml || ! -e project-sm.yml || ! -e project-action.yml ]]; then
             echo "[ERROR] Ceedling project not found"
             exit 1
         else
            ceedling clean
            ceedling clobber
         fi
    done

    currdir=$PWD
    for module in $modules;
    do
        title "Clean "$module "module"
        cd $source_dir/$module
        if [ ! -e "project.yml" ]; then
            echo "[ERROR] Ceedling project not found"
            exit 1
        else
            ceedling clean
            ceedling clobber
        fi
    done

    for module in $exceptionModules;
    do
        title "Clean "$module "module"
        cd $source_dir/$module
        if [ ! -e "project.yml" ]; then
            echo "[ERROR] Ceedling project not found"
            exit 1
        else
            ceedling clobber
        fi
    done
}

testModuleExceptions()
{
    title "Run all test of ModuleB module"
    cd $source_dir/ModuleB
    if [ ! -e "project.yml" ]; then
        echo "[ERROR] Ceedling project not found"
        exit 1
    else
        if [ $clobber == 0 ]; then
            ceedling clean gcov:ffile
            ceedling clean options:project-ffdir gcov:ffdir
            ceedling clean options:project-complete-eeprom gcov:ffile-complete
            ceedling clean options:project-complete-dataflash gcov:ffile-complete
        else
            ceedling clean clobber gcov:ffile
            ceedling clean clobber options:project-ffdir gcov:ffdir
            ceedling clean clobber options:project-complete-eeprom gcov:ffile-complete
            ceedling clean clobber options:project-complete-dataflash gcov:ffile-complete
        fi
    fi

}

releaseModules()
{
    title "Release FrameConv module"
    cd $source_dir/FrameConv
    if [ ! -e "project.yml" ]; then
        echo "[ERROR] Ceedling project not found"
        exit 1
    else
        ceedling release
    fi
}

coverModuleExceptions()
{
    title  "Generating code coverage report for ffile"
    cd $currdir
    cd $source_dir/ffile
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/ffile.c" -o ../../$ceedling_dir/gcov/ffile.info
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/devflash.c" -o ../../$ceedling_dir/gcov/devflash.info
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/rfile.c" -o ../../$ceedling_dir/gcov/rfile.info
    add+=(-a devflash.info)
    add+=(-a ffile.info)
    add+=(-a rfile.info)

    title "Generating code coverage report for Backup"
    cd $currdir
    cd $source_dir/Backup
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/Backup.c" -o ../../$ceedling_dir/gcov/Backup.info
    add+=(-a Backup.info)

    title "Generating code coverage report for gps"
    cd $currdir
    cd $source_dir/gps
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/Geo.c" -o ../../$ceedling_dir/gcov/Geo.info
    add+=(-a Geo.info)
}

case "$1" in
    clean)
        clobber=1
        ;;
    clobber)
        cleanModules
        exit 0
        ;;
    *)
        clobber=0
        ;;
esac

currdir=$PWD
for module in $modules;
do
    title "Run all test of "$module "module"
    cd $source_dir/$module
     if [ ! -e "project.yml" ]; then
         echo "[ERROR] Ceedling project not found"
         exit 1
     else
         if [ $clobber == 0 ]; then
             ceedling clean gcov:all
         else
             ceedling clean clobber gcov:all
         fi
     fi
done

for sm in $stateMachines;
do
    title "Run all test of "$sm "state machine"
    cd $source_dir/$sm
     if [[ ! -e "project.yml" || ! -e "project-sm.yml" || ! -e "project-action.yml" ]]; then
         echo "[ERROR] Ceedling project not found"
         exit 1
     else
         if [ $clobber == 0 ]; then
             ceedling clean options:project-sm gcov:$sm
             ceedling clean options:project-action gcov:$sm"Act"
         else
             ceedling clean clobber options:project-sm gcov:$sm
             ceedling clean clobber options:project-action gcov:$sm"Act"
         fi
     fi
done

testModuleExceptions
releaseModules

title "Generating code coverage report for modules"
cd ..
lcov -c -d . -o ../$ceedling_dir/gcov/coverage-total.info
add=()
for module in $modules;
do
    cd $currdir
    cd $source_dir/$module
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/$module*.c" -o ../../$ceedling_dir/gcov/$module.info
    add+=(-a $module".info")
#   cd $source_dir/$module/test/
#   submodules=(`find . -name "test_rkh*.c" -type f | sort -r | head -8 | sed 's/\.\\/test_//' | sed 's/\.c//'`)
#   cd ..
#   find build/gcov/out/ ! -name rkh$module*.gc* -type f | xargs sudo rm -f
done

title "Generating code coverage report for state machines"
for sm in $stateMachines;
do
    cd $currdir
    cd $source_dir/$sm
    #lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/$sm.c" -o ../../$ceedling_dir/gcov/$sm.info
    #add+=(-a $sm".info")
    lcov -e ../../$ceedling_dir/gcov/coverage-total.info "$(pwd)/src/$sm"Act".c" -o ../../$ceedling_dir/gcov/$sm"Act".info
    add+=(-a $sm"Act"".info")
done

coverModuleExceptions

title "Generating complete code coverage report"
cd ../../$ceedling_dir/gcov/
lcov "${add[@]}" -o coverage.info
genhtml coverage.info -o .
if [ ! -z $CODECOV_TOKEN ]; then
    bash <(curl -s https://codecov.io/bash)
fi

exit 0

