#!/bin/zsh

if [ $# -lt 2 ];
then
  echo "USAGE:$# $0 service [start|stop|restart] "
  exit 1
fi
service=$1
cmd=$2
kafka_home="/Users/fuqiangnian/dev/kafka/kafka_2.11-2.4.1"
supported_services=("redis" "kafka" "nacos")
brew_service=("postgresql" "rabbitmq" "nginx")
#supported_services_str=$(printf ",%s" "${supported_services[@]}")
supported_services_str=$(IFS=, ; echo "${supported_services[*]}")
if [[ ! " ${supported_services[*]} " =~ " ${service} " ]]; then
    # 如果传入的service 不在 supported_services 中
    if [[ ! " ${brew_service[*]} " =~ " ${service} " ]]; then

        echo "supported services are: "$supported_services_str","$(IFS=, ; echo "${brew_service[*]}")
        exit 1  
    fi
    exec brew services $cmd $service

fi


run_stop(){
    PIDS=$1
    services=$2
    SIGNAL=TERM
    if [ -z "$PIDS" ]; then
        echo "No $services server to stop"
        exit 1
    else
        echo "killing $services server pid: $PIDS"
        kill -s $SIGNAL $PIDS
    fi 
}



stop_kafka(){
    cd $kafka_home 
    bin/zookeeper-server-stop.sh
    PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

    if [ -z "$PIDS" ]; then
        echo "No kafka server to stop"
        exit 1
    else
        kill -9 $PIDS
    fi
}
start_kafka(){
    cd $kafka_home
    bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
    bin/kafka-server-start.sh -daemon config/server.properties
}

start_redis() {
    cd /Users/fuqiangnian/dev/redis-3.2.3/
    ./src/redis-server redis.conf
    echo "redis server started"
}
stop_redis(){
    PIDS=$(ps ax | grep -i 'redis-server' | grep -v grep | awk '{print $1}')
    SIGNAL=TERM
    if [ -z "$PIDS" ]; then
        echo "No redis server to stop"
        exit 1
    else
        echo "killing redis server pid: $PIDS"
        kill -s $SIGNAL $PIDS
        echo "redis server shutdown"

    fi 
}

start_nacos(){
    sh /Users/fuqiangnian/dev/nacos-server-1.4.2/bin/startup.sh -m standalone
}
stop_nacos(){
    exec /Users/fuqiangnian/dev/nacos-server-1.4.2/bin/shutdown.sh
}


stop(){
    service=$1
    case "$service" in
    redis)
        stop_redis
        ;;
    kafka)
        stop_kafka
        ;; 
    nacos)
        stop_nacos
        ;;
    *)
        echo "service $service Temporarily unsupported! try $supported_services_str "
        exit 1
        ;;
    esac

}


start(){

    service=$1
    case "$service" in
    redis)
        start_redis
        ;;
    kafka)
        start_kafka
        ;; 
    nacos)
        start_nacos
        ;;
    *)
        echo "service $service Temporarily unsupported! try $supported_services_str "
        exit 1
        ;;
    esac

}

restart(){
    service=$1 
    case "$service" in
    redis)
        stop_redis
        start_redis
        ;;
    kafka)
        stop_kafka
        start_kafka
        ;; 
    nacos)
        stop_nacos
        start_nacos
        ;;
    *)
        echo "service $service Temporarily unsupported! try $supported_services_str "
        exit 1
        ;;
    esac
}

case "$cmd" in 
    s|start)
            echo "starting $service ..."
            start $service
            ;;
    stop)
            echo "stopping $service ..."
            stop $service
            ;;
    restart)
            echo "restart $service ..."
            restart $service
            ;;
    *)
        echo "USAGE: $0 service [start|stop|restart]"
        exit 1
        ;;
esac
