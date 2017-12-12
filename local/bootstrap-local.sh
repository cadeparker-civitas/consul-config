#!/bin/sh

# get the directory of the script so we know where the config file is located
BOOTSTRAP_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BOOTSTRAP_CONFIG=$BOOTSTRAP_DIR/config.json

if ! [ -x "$(command -v consul)" ]; then
  echo "Could not find installed consul. Running docker image instead..."
  # if the consul docker process isn't running, then start a new container
  if [ ! "$(docker ps -q -f ancestor=consul)" ]; then
    echo "Starting Consul..."

    echo "command: docker run -d -p 8500:8500 consul"
    docker run -d -p 8500:8500 consul

    # wait for the consul agent to start
    sleep 5
  else
    echo "Consul is already running..."
  fi
else
  if pgrep -x "consul" > /dev/null
  then
    echo "Consul is already running..."

  else
    echo "Starting Consul..."

    echo "command: consul agent -dev"
    consul agent -dev &> /dev/null &
  fi
fi

echo "Running git2consul with config:"

cat ${BOOTSTRAP_CONFIG}

echo "\n"

git2consul --config-file ${BOOTSTRAP_CONFIG}