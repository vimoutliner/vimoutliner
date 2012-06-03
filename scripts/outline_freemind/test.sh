#!/bin/sh

tmp=/tmp
dirname=`dirname $0`
fname=$dirname/test.otl
[ -n "$1" ] && fname=$1

$dirname/freemind.py -m $fname > $tmp/test.mm
$dirname/freemind.py -o $tmp/test.mm > $tmp/return.otl
diff -Nur $fname $tmp/return.otl
