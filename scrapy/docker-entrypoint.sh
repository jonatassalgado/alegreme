#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

scrapy-do-cl jon push-project
# scrapy-do-cl schedule-job --project alegreme --spider event --when 'every day at 01:00'

exec "$@"
# Finally call command issued to the docker service
