#!/bin/bash
# load common goto utils
source _gotoutils
source start_goto

TESTPROJECT=testproject
OUTPUTFILE=/tmp/.gototest-cmd-output

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


function set_up {
    if [[ -z "$GOTOPATH" ]]; then
        echo "GOTOPATH not set in environment."
        echo "Tests should not run on real goto state folder."
        echo "i.e use GOTOPATH=/tmp/.goto   instead"
        exit 1
    fi
    echo "setting up tests"
    create_goto_folders "$GOTOPATH"
    touch "$OUTPUTFILE"
}


function _fail_test {
    message=$1
    echo -e "${RED}Test failed - $message${NC}"
    echo "OUTPUT: $(cat "$OUTPUTFILE")"
    _display_projectfile
    echo "Test failed - $message"
    tear_down
    exit 1
}

function _cmd_should_fail {
    cmd=$1
    if $cmd &> "$OUTPUTFILE"; then
        _fail_test "command: '$cmd' should fail, but did not."
    else
        return 0
    fi
}
_cmd_should_fail "ls nosuchfile"


function _cmd_should_succeed {
    cmd=$1
    if $cmd &> "$OUTPUTFILE"; then
        return 0
    else 
        _fail_test "command: '$cmd' should succeed, but did not."
    fi
}
_cmd_should_succeed "ls"


function _cmd_should_be_empty {
    cmd=$1
    $cmd &> "$OUTPUTFILE"
    result="$(cat "$OUTPUTFILE")"
    if [ -n "$result" ]; then
        _fail_test "command: '$cmd' did not return empty"
    else
        return 0
    fi
}

function _failing_cmd_should_give_human_message {
    cmd=$1
    $cmd &> "$OUTPUTFILE"
    result="$(cat "$OUTPUTFILE")"
    if [[ ! "$result" =~ "Ah hoy" ]]; then
        _fail_test "command: '$cmd' did not give human readable error message"
    else
        return 0
    fi
}

function _display_projectfile {
    projectfile="$GOTOPATH/projects/$TESTPROJECT.json"
    echo "Contents of projectfile $projectfile:"
    if [ -f "$projectfile" ]; then
        cat "$projectfile"
    else
        echo "projectfile $projectfile is not existing"
    fi
}


function test_00_deactivate_project {
    _cmd_should_succeed "project deactivate"
}

function test_01_switch_to_nonexistent_project {
    _cmd_should_fail "project $TESTPROJECT"
    _cmd_should_fail "goto list"
}

function test_02_add_project {
    _cmd_should_succeed "project add $TESTPROJECT"
    if [ ! -f "${GOTOPATH}/projects/${TESTPROJECT}" ]; then
        _fail_test "project file not created"
    fi
    _cmd_should_succeed "goto list"
}


function test_03_goto_add {
    magicword="test_add"
    uri="http://example.com"

    _cmd_should_succeed "goto add $magicword $uri"
    # Adding magicword that already exist
    _cmd_should_fail "goto add $magicword $uri"
}


function test_04_goto_show {
    existing_magicword="test_show"
    nonexisting_magicword="IDoNotExist"
    uri="http://example.com"

    _cmd_should_succeed "goto add $existing_magicword $uri"

    # Invoking show without any magic words
    _cmd_should_fail "goto show"
    _failing_cmd_should_give_human_message "goto show"
    
    _cmd_should_succeed "goto show $existing_magicword"

    _cmd_should_fail "goto show $nonexisting_magicword"
    _failing_cmd_should_give_human_message "goto show $nonexisting_magicword"
}


function tear_down {
    if [[ -n "$GOTOPATH" && -d "$GOTOPATH" ]]; then
        rm -rf "$GOTOPATH"
    fi

    rm "$OUTPUTFILE"
}

function discover_and_run_tests {
    functions=$(declare -F | cut -d ' ' -f3)
    DISCOVERED_TESTS=0
    for f in $functions; do
        
        if [[ "$f" == test_* ]]; then
            let DISCOVERED_TESTS=DISCOVERED_TESTS+1
            echo "$f"
            $f
        fi
    done

    echo -e "${GREEN}All tests passed!${NC}"
    echo "ran $DISCOVERED_TESTS tests successfully!"

}


set_up
discover_and_run_tests
tear_down
