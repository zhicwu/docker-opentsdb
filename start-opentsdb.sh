#!/bin/bash
SERVICE_NAME=opentsdb

DOCKER_CONTAINER_ALIAS="my-$SERVICE_NAME"
DOCKER_IMAGE_TAG="latest"

CONF_FILE=opentsdb.conf

cdir="`dirname "$0"`"
cdir="`cd "$cdir"; pwd`"

[[ "$TRACE" ]] && set -x

_log() {
  [[ "$2" ]] && echo "[`date +'%Y-%m-%d %H:%M:%S.%N'`] - $1 - $2"
}

info() {
  [[ "$1" ]] && _log "INFO" "$1"
}

warn() {
  [[ "$1" ]] && _log "WARN" "$1"
}

setup_env() {
  info "Load environment variables from $cdir/$SERVICE_NAME-env.sh..."
  if [ -f $cdir/$SERVICE_NAME-env.sh ]
  then
    . "$cdir/$SERVICE_NAME-env.sh"
  else
    warn "Skip $SERVICE_NAME-env.sh as it does not exist"
  fi

  # check environment variables and set defaults as required
  : ${ZK_QUORUM:="zk"}
  : ${ZK_BASEDIR:="hbase"}
  : ${AUTO_CREATE_METRICS:="true"}
  : ${CONF_DIR:="$cdir/conf"}
  : ${DATA_DIR:="$cdir/data"}

  info "Loaded environment variables:"
  info "           ZK_QUORUM = $ZK_QUORUM"
  info "          ZK_BASEDIR = $ZK_BASEDIR"
  info " AUTO_CREATE_METRICS = $AUTO_CREATE_METRICS"
  info "            CONF_DIR = $CONF_DIR"
  info "            DATA_DIR = $DATA_DIR"
}

setup_dir() {
  if [ -d $CONF_DIR ]; then
    info "Reuse existing configuration directory: $CONF_DIR"
  else
    info "Initialize Configuration directory: $CONF_DIR"
    mkdir -p $CONF_DIR
  fi

  if [ ! -f $CONF_DIR/$CONF_FILE ]; then
    warn "$CONF_FILE not found, generate one with default settings..."
    echo "tsd.storage.hbase.zk_quorum  = $ZK_QUORUM" > $CONF_DIR/$CONF_FILE
    echo "tsd.storage.hbase.zk_basedir = $ZK_BASEDIR" >> $CONF_DIR/$CONF_FILE
    echo "tsd.core.auto_create_metrics = $AUTO_CREATE_METRICS" >> $CONF_DIR/$CONF_FILE
    cat $CONF_DIR/$CONF_FILE
  else
    sed -ri 's/^(tsd.storage.hbase.zk_quorum).*/\1  = '"$ZK_QUORUM"'/' "$CONF_DIR/$CONF_FILE"
    sed -ri 's/^(tsd.storage.hbase.zk_basedir).*/\1 = '"$ZK_BASEDIR"'/' "$CONF_DIR/$CONF_FILE"
    sed -ri 's/^(tsd.core.auto_create_metrics).*/\1 = '"$AUTO_CREATE_METRICS"'/' "$CONF_DIR/$CONF_FILE"
  fi

  if [ -d $DATA_DIR ]; then
    info "Reuse existing data directory: $DATA_DIR"
  else
    info "Initialize data directory: $DATA_DIR"
    mkdir -p $DATA_DIR
  fi
}

start_service() {
  info "Stop and remove \"$DOCKER_CONTAINER_ALIAS\" if it exists and start new one"
  # stop and remove the container if it exists
  docker stop "$DOCKER_CONTAINER_ALIAS" >/dev/null 2>&1 && docker rm "$DOCKER_CONTAINER_ALIAS" >/dev/null 2>&1

  docker run -d --name="$DOCKER_CONTAINER_ALIAS" --net=host --restart=always \
    -v $CONF_DIR:/etc/opentsdb:Z -v $DATA_DIR:/opentsdb/cache:Z \
    zhicwu/$SERVICE_NAME:$DOCKER_IMAGE_TAG

  info "Try 'docker logs -f \"$DOCKER_CONTAINER_ALIAS\"' to see if this works"
}

main() {
  setup_env
  setup_dir
  start_service
}

main "$@"
