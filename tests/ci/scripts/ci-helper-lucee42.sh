#!/bin/bash
case $1 in
	start)
		CONTROL_SCRIPT='start.sh'
		;;
	stop)
		CONTROL_SCRIPT='stop.sh'
		;;
esac

PLATFORM_DIR="lucee"
WEBROOT="webapps/ROOT"
MY_DIR=`dirname $0`
source $MY_DIR/ci-helper-base.sh $1 $2

case $1 in
	install)
		chmod a+x start.sh
		chmod a+x stop.sh

		sed -i "s/jetty.port=8888/jetty.port=$SERVER_PORT/g" start.sh
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" start.sh
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" stop.sh
		;;
	start|stop)
		;;
	*)
		echo "Usage: $0 {install|start|stop}"
		exit 1
		;;
esac

exit 0
