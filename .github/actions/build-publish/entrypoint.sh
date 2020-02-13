#!/bin/sh

if [ -z "$1" ]; then
	echo "Tag to build against must be provided!"
	exit 1
else
	TAG=$1
fi

set -e

if [ -z "${INPUT_USERNAME}" ]; then
  echo "Username is empty. Please set with.username to login to docker registry."
fi

if [ -z "${INPUT_PASSWORD}" ]; then
  echo "Password is empty. Please set with.password to login to docker registry."
fi

echo "${INPUT_PASSWORD}" | docker login -u ${INPUT_USERNAME} --password-stdin ${INPUT_REGISTRY}

# check if we should pull existing images to help speed up the build
if [ "${INPUT_PULL}" == "true" ]; then
	sh -c "docker pull nxtlvlsoftware/pmmp:'$TAG'"
	sh -c "docker pull nxtlvlsoftware/pmmp-phpstan:'$TAG'"
fi

# build the base pmmp image
sh -c "cd pocketmine-mp && docker build --from-cache='nxtlvlsoftware/pmmp:'$TAG'' -t nxtlvlsoftware/pmmp:'$TAG' --build-arg PMMP_TAG='$TAG' ."

# build the pmmp phpstan image
sh -c "cd phpstan && docker build -t --from-cache='nxtlvlsoftware/pmmp-phpstan:'$TAG'' nxtlvlsoftware/pmmp-phpstan:'$TAG' --build-arg TAG='$TAG' ."

# publish the builds to docker hub
sh -c "docker push nxtlvlsoftware/pmmp:'$TAG' && docker push nxtlvlsoftware/pmmp-phpstan:'$TAG'"