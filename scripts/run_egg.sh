#!/bin/bash

#  run_egg.sh
#  roborobo
#
#  Created by Berend Weel on 10/16/12.
#

FULLCOMMAND="$0 $@"

# Parse the flags
FLAGS "$@" || exit 1
eval set -- "${FlAGS_ARGV}"

RID=$RANDOM

### copy the template configuration to the config dir, making the neccesary adjustments
# Determine some properties of the test
ROBOTCOUNT=${FLAGS_robots}
TIMESTAMP=`date "+%Y%m%d.%Hh%Mm%Ss"`
ESCAPEDLOGDIR=$(sed -e 's/[\/&]/\\&/g' <<< $LOGDIR)

# Determine where the configuration file will be placed
CONFDIR=${BASEDIR}config/
CONFFILE=${CONFDIR}${TIMESTAMP}.$RID.${TESTNAME}.$ROBOTCOUNT.properties
LOGFILE=${BASEDIR}/${LOGDIR}/console-output.${TIMESTAMP}.$RID.log
ERRORLOGFILE=${BASEDIR}/${LOGDIR}/console-error.${TIMESTAMP}.$RID.log

OUTPUTLOGFILE=${ESCAPEDLOGDIR}\\/output.${TIMESTAMP}.$RID.log
ORGANISMSIZESLOGFILE=${ESCAPEDLOGDIR}\\/organism-sizes.${TIMESTAMP}.$RID.log
POPLOGFILE=${ESCAPEDLOGDIR}\\/pop.${TIMESTAMP}.$RID.log
EVENTLOGFILE=${ESCAPEDLOGDIR}\\/event.${TIMESTAMP}.$RID.log
GENOMEORGLOGFILE=${ESCAPEDLOGDIR}\\/genomesOrg.${TIMESTAMP}.$RID.log
TRAVELLOGFILE=${ESCAPEDLOGDIR}\\/travel.${TIMESTAMP}.$RID.log
HEATMAPLOGFILE=${ESCAPEDLOGDIR}\\/heatmap.${TIMESTAMP}.$RID
LOCATIONLOGFILE=${ESCAPEDLOGDIR}\\/locations.${TIMESTAMP}.$RID.log

# Prepare the rules that will fill out the configuration file
SEEDREP=s/--RANDOMSEED/${FLAGS_seed:0:9}/g # extract only the first 9 decimals, because Roborobo can't handle int overflows
NBAGENTSREP=s/--NBAGENTS/${ROBOTCOUNT}/g
ITERATIONREP=s/--ITERATIONS/${FLAGS_iterations}/g

MAXEGGLIFEREP=s/--EGGLIFETIME/${FLAGS_maxEggLifetime}/g
MAXSEEDLIFEREP=s/--SEEDLIFETIME/${FLAGS_maxSeedLifetime}/g
MAXORGLIFEREP=s/--ORGANISMLIFETIME/${FLAGS_maxOrganismLifetime}/g
SEEDBROADCASTRANGEREP=s/--SEEDBROADCASTRANGE/${FLAGS_maxSeedBoardcastRange}/g
ORGANISMBROADCASTRANGEREP=s/--ORGANISMBROADCASTRANGE/${FLAGS_maxOrganismBoardcastRange}/g

MAXORGSIZEREP=s/--MAXORGSIZE/${FLAGS_maxOrganismSize}/g
MINORGSIZEREP=s/--MINORGSIZE/${FLAGS_minOrganismSize}/g
CONNECTIONTYPEREP=s/--CONNECTIONTYPE/${FLAGS_connectionType}/g

OUTPUTLOGREP=s/--OUTPUTLOG/${OUTPUTLOGFILE}/g
ORGANISMSIZESREP=s/--ORGANISMSIZESLOG/${ORGANISMSIZESLOGFILE}/g
LOCATIONREP=s/--LOCATIONLOG/${LOCATIONLOGFILE}/g
POPLOGREP=s/--POPLOG/${POPLOGFILE}/g
EVENTLOGREP=s/--EVENTLOG/${EVENTLOGFILE}/g
GENOMEORGLOGREP=s/--GENOMEORGLOG/${GENOMEORGLOGFILE}/g
TRAVELLOGREP=s/--TRAVELLOG/${TRAVELLOGFILE}/g
HEATMAPLOGREP=s/--HEATMAPLOG/${HEATMAPLOGFILE}/g

# Fill out and place the configuration file
sed -e $SEEDREP -e $NBAGENTSREP -e $OUTPUTLOGREP -e $ORGANISMSIZESREP -e $POPLOGREP -e $EVENTLOGREP -e $GENOMEORGLOGREP -e $TRAVELLOGREP -e $ITERATIONREP -e $LOCATIONREP -e $HEATMAPLOGREP -e $MAXEGGLIFEREP -e $MAXSEEDLIFEREP -e $MAXORGLIFEREP -e $SEEDBROADCASTRANGEREP -e $ORGANISMBROADCASTRANGEREP -e $MAXORGSIZEREP -e $MINORGSIZEREP -e $CONNECTIONTYPEREP ${BASEDIR}${TEMPLATEDIR}${CONFNAME}.template.properties > $CONFFILE

if [ $? -ne 0 ]
then
    exit $?
fi

### Run RoboRobo!
BINFILE=${BASEDIR}/DerivedData/roborobo/Build/Products/Debug/roborobo.app/Contents/MacOS/roborobo
$BINFILE -l $CONFFILE > >(tee $LOGFILE) 2> >(tee $ERRORLOGFILE >&2)