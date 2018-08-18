#!/bin/bash

docker container prune -f --filter=label=`cat ./proj_name`
