# parent folder of all outlines
OUTLINES=$HOME/Outlines

# folder for calendar files
# should be a subfolder of $OUTLINES
CALENDAR=$OUTLINES/outline_calendar

# file for calendar tags
CALENDARTAGS=$CALENDAR/vo_calendar_tags.tag

# folders to tag for interoutline links and calendar access
# if $CALENDAR is not below $OUTLINES, you need
#   TAGFOLDERS=($OUTLINES $CALENDAR)
TAGFOLDERS=($OUTLINES)

# script to generate calendar skeletons
CALGENSCRIPT=$CALENDAR/vo_calendar_generator.rb

# option file for ctags
CTAGSOPTIONS=$CALENDAR/vo_calendar_ctags.conf


# you should not need to change anything below here
# that's what all the variables above are for
# ------------------------------------------------------------

function td() {
  local date
  date=${1:-`date +%Y-%m-%d`}
  ${DISPLAY:+g}vim -c ":ta $date" $CALENDAR/${date%%-*}.otl
}

function tagvout() {
  ctags -f $CALENDARTAGS --options=$CTAGSOPTIONS ${TAGFOLDERS[*]}
}

function calgen() {
  $CALGENSCRIPT $CALENDAR $*
}
