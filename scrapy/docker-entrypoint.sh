#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

# scrapy-do-cl --url http://184.73.66.107:7654 push-project
# scrapy-do-cl schedule-job --url http://scrapy:7654 --project alegreme --spider event --when 'every day at 01:00'

exec "$@"
# Finally call command issued to the docker service
