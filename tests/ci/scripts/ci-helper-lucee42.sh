#!/bin/bash
case $1 in
	start)
		CONTROL_SCRIPT='lucee-4.5.0.042-express/start.sh'
		;;
	stop)
		CONTROL_SCRIPT='lucee-4.5.0.042-express/stop.sh'
		;;
esac

PLATFORM_DIR="lucee-4.5.0.042-express"
WEBROOT="lucee-4.5.0.042-express/webapps/ROOT"
MY_DIR=`dirname $0`
source $MY_DIR/ci-helper-base.sh $1 $2

case $1 in
	install)
		chmod a+x lucee-4.5.0.042-express/start.sh
		chmod a+x lucee-4.5.0.042-express/stop.sh

		sed -i "s/jetty.port=8888/jetty.port=$SERVER_PORT/g" lucee-4.5.0.042-express/start.sh
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" lucee-4.5.0.042-express/start.sh
		sed -i "s/STOP.PORT=8887/STOP.PORT=$STOP_PORT/g" lucee-4.5.0.042-express/stop.sh
		;;
	start|stop)
		;;
	*)
		echo "Usage: $0 {install|start|stop}"
		exit 1
		;;
esac

exit 0
