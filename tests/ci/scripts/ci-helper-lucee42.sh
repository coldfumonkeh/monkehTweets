#!/bin/bash
case $1 in
	start)
		CONTROL_SCRIPT='lucee/start'
		;;
	stop)
		CONTROL_SCRIPT='lucee/stop'
		;;
esac

PLATFORM_DIR="lucee"
WEBROOT="lucee/webapps/ROOT"
MY_DIR=`dirname $0`
source $MY_DIR/ci-helper-base.sh $1 $2

case $1 in
	install)
		chmod a+x lucee/start
		chmod a+x lucee/stop

		sed -i "s/jetty.port=8888/jetty.port=$SERVER_PORT/g" lucee/start
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" lucee/start
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" lucee/stop
		;;
	start|stop)
		;;
	*)
		echo "Usage: $0 {install|start|stop}"
		exit 1
		;;
esac

exit 0
