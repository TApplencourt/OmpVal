#!/usr/bin/env bash
DOC="Omphval.sh a OpenMP test generator.
Usage:
  ovo.sh gen
  ovo.sh run [<test_folder>...] [--no_long_double] [--no_loop]
  ovo.sh display [--detailed] [--failed] [--passed] [--no_long_double] [--no_loop] [<result_folder>...]
  ovo.sh clean
"

# You are Not Expected to Understand This
# docopt parser below, refresh this parser with `docopt.sh ovo.sh`
# shellcheck disable=2016,1091,2034
docopt() { source src/docopt-lib.sh '0.9.15' || { ret=$?
printf -- "exit %d\n" "$ret"; exit "$ret"; }; set -e; trimmed_doc=${DOC:0:237}
usage=${DOC:36:201}; digest=4aad4; shorts=('' '' '' '' '')
longs=(--no_long_double --no_loop --detailed --failed --passed)
argcounts=(0 0 0 0 0); node_0(){ switch __no_long_double 0; }; node_1(){
switch __no_loop 1; }; node_2(){ switch __detailed 2; }; node_3(){
switch __failed 3; }; node_4(){ switch __passed 4; }; node_5(){
value _test_folder_ a true; }; node_6(){ value _result_folder_ a true; }
node_7(){ _command gen; }; node_8(){ _command run; }; node_9(){ _command display
}; node_10(){ _command clean; }; node_11(){ required 7; }; node_12(){
oneormore 5; }; node_13(){ optional 12; }; node_14(){ optional 0; }; node_15(){
optional 1; }; node_16(){ required 8 13 14 15; }; node_17(){ optional 2; }
node_18(){ optional 3; }; node_19(){ optional 4; }; node_20(){ oneormore 6; }
node_21(){ optional 20; }; node_22(){ required 9 17 18 19 14 15 21; }
node_23(){ required 10; }; node_24(){ either 11 16 22 23; }; node_25(){
required 24; }; cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:36:201}" >&2; exit 1; }'; unset var___no_long_double \
var___no_loop var___detailed var___failed var___passed var__test_folder_ \
var__result_folder_ var_gen var_run var_display var_clean; parse 25 "$@"
local prefix=${DOCOPT_PREFIX:-''}; local docopt_decl=1
[[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2
unset "${prefix}__no_long_double" "${prefix}__no_loop" "${prefix}__detailed" \
"${prefix}__failed" "${prefix}__passed" "${prefix}_test_folder_" \
"${prefix}_result_folder_" "${prefix}gen" "${prefix}run" "${prefix}display" \
"${prefix}clean"
eval "${prefix}"'__no_long_double=${var___no_long_double:-false}'
eval "${prefix}"'__no_loop=${var___no_loop:-false}'
eval "${prefix}"'__detailed=${var___detailed:-false}'
eval "${prefix}"'__failed=${var___failed:-false}'
eval "${prefix}"'__passed=${var___passed:-false}'
if declare -p var__test_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_test_folder_=("${var__test_folder_[@]}")'; else
eval "${prefix}"'_test_folder_=()'; fi
if declare -p var__result_folder_ >/dev/null 2>&1; then
eval "${prefix}"'_result_folder_=("${var__result_folder_[@]}")'; else
eval "${prefix}"'_result_folder_=()'; fi
eval "${prefix}"'gen=${var_gen:-false}'; eval "${prefix}"'run=${var_run:-false}'
eval "${prefix}"'display=${var_display:-false}'
eval "${prefix}"'clean=${var_clean:-false}'; local docopt_i=0
for ((docopt_i=0;docopt_i<docopt_decl;docopt_i++)); do
declare -p "${prefix}__no_long_double" "${prefix}__no_loop" \
"${prefix}__detailed" "${prefix}__failed" "${prefix}__passed" \
"${prefix}_test_folder_" "${prefix}_result_folder_" "${prefix}gen" \
"${prefix}run" "${prefix}display" "${prefix}clean"; done; }
# docopt parser above, complete command for generating this parser is `docopt.sh --library=src/docopt-lib.sh ovo.sh`

#We don't use the most straitforward `find . -type d -links 2`
#Because on MaxOS and the Travis PowerPC links includes current,parent and sub directories but also files.  
#  LC_ALL=C is to get the tradional  sort order. Solve issue with reduction , reduction_atomic
fl_folder(){
    local folders=$(find $(realpath "${@}") -type d |  LC_ALL=C sort | uniq | awk '$0 !~ last "/" {print last} {last=$0} END {print last}')
    echo $(realpath ${folders}  --relative-to=$PWD)
}

fl_test_src() {
    if [ -z "$1" ]
    then
        echo $(fl_folder "test_src")
    else
        echo $(fl_folder "${@}")
    fi
}

frun() {
    local uuid=$(date +"%Y-%m-%d_%H-%M")
    local result="test_result/${uuid}_$(hostname)"

    for dir in $(fl_test_src $@)
    do
        nresult=$result/${dir#*/}
        echo "Running $dir | Saving log in $nresult"

        mkdir -p "$nresult"
        env > "$nresult"/env.log
        if ${__no_long_double}
        then
            make --no-print-directory -C "$dir" exe_no_long_double |& tee "$nresult"/compilation.log
        elif ${__no_loop}
        then
            make --no-print-directory -C "$dir" exe_no_loop |& tee "$nresult"/compilation.log
        else
            make --no-print-directory -C "$dir" exe |& tee "$nresult"/compilation.log
        fi
        make --no-print-directory -C "$dir" run |& tee "$nresult"/runtime.log
    done
}

fdisplay() {

    if [ -z "$1" ]
    then
      # Get the last modified folder in results, then list all the tests avalaible inside.
      local folders="$(find test_result -maxdepth 1 -type d | tail -n 1)"
    else
      local folders="${@}"   
    fi

    ./src/display.py "${__detailed}" "${__failed}" "${__passed}" "${__no_long_double}" "${__no_loop}" "${#_result_folder_[@]}" $(fl_folder ${folders})
}

fclean() {
    for dir in $(fl_test_src $@)
    do
        make -s -C "$dir" "clean"
    done
}

#  _
# |_) _. ._ _ o ._   _     /\  ._ _
# |  (_| | _> | | | (_|   /--\ | (_| \/
#                    _|           _|
eval "$(docopt "$@")"

$gen && rm -rf -- ./test_src && ./src/gtest.py 
$run && fclean "${_result_folder_[@]}" && frun "${_test_folder_[@]}"
$display && fdisplay "${_result_folder_[@]}"
$clean && fclean
exit 0
