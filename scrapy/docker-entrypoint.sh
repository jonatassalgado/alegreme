#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# scrapy-do-cl --username jon --password password --url http://3.223.33.161:7654 push-project
# scrapy-do-cl --username jon --password password --url http://3.223.33.161:7654 schedule-job --project alegreme --spider event --when 'every day at 01:00'

exec "$@"
# Finally call command issued to the docker service
