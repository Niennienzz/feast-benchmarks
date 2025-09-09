#!/bin/bash

UNIQUE_REQUESTS_NUM=${UNIQUE_REQUESTS_NUM:-1000}
CONCURRENCY=${CONCURRENCY:-5}
RUN_TIME=${RUN_TIME:-1m}
WAIT_TIME=${WAIT_TIME:-1}
REQUEST_TIMEOUT=${REQUEST_TIMEOUT:-5s}

ENDPOINTS=()
while IFS= read -r line; do
  ENDPOINTS+=( "$line" )
done < run_benchmark_endpoints.txt

ENDPOINT_ARGS=""
for endpoint in "${ENDPOINTS[@]}"; do
  ENDPOINT_ARGS="$ENDPOINT_ARGS --endpoints $endpoint"
  echo "Using endpoint: $endpoint"
done

trap "exit" INT

run_benchmark() {
	echo "Entity rows: $1; Features: $2; Concurrency: $3; RPS: $4"

	uv run run_benchmark_gen_requests.py \
	  $ENDPOINT_ARGS \
		--entity-rows $1 \
		--features $2 \
		--requests ${UNIQUE_REQUESTS_NUM} \
		--output requests-$1-$2.json

	echo "vegeta attack -format json -targets requests-$1-$2.json -connections $3 -duration ${RUN_TIME} -rate $4/1s -timeout ${REQUEST_TIMEOUT} | vegeta report"

	vegeta attack -format json -targets requests-$1-$2.json -connections $3 -duration ${RUN_TIME} -rate $4/1s -timeout ${REQUEST_TIMEOUT} | vegeta report

	sleep ${WAIT_TIME}
}

# run_benchmark <entities> <features> <concurrency> <rps>
run_benchmark 10 50 5 10
# run_benchmark 100 250 1000 1000
