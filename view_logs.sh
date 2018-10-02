#!/bin/bash

docker-compose  --project-name `cat ./proj_name` logs -f -t
