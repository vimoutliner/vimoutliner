outputdir=/tmp
#fname=$1
fname=test.otl
python outline_freemind.py $fname > $outputdir/test.mm
python freemind_outline.py $outputdir/test.mm > $outputdir/return.otl
diff $fname $outputdir/return.otl
