# Feast Benchmark Suite

- Install dependencies using [`uv`](https://github.com/astral-sh/uv):

```bash
$>  uv sync
```

- Generate the benchmark data (which is saved as `generated_data.parquet`):

```bash
$> uv run generated_data.py
```

- Configure Feast and apply the feature definitions by running `feast apply`.
  - The command relies on `feature_store.yaml` for offline and online store configurations.
  - The command relies on `feature_store.py` for feature object definitions (entities, feature views, etc.).

```bash
$> uv run feast apply
```

- Materialize features to the online store:

```bash
$> uv run feast materialize-incremental $(date -u +"%Y-%m-%dT%H:%M:%S")
```

- Run the Feast server as shown below.
  - In this benchmark, we can use multiple servers running Feast.
  - If you want to switch the online store, you can modify `feature_store.yaml` accordingly.
  - After the modification, rerun `feast apply` and `feast materialize-incremental`.
  - Note that `feast apply` needs to be run on each server, while `feast materialize-incremental` only needs to be run once.

```bash
$> uv run feast serve
```

- Run the benchmark suite by executing the `run_benchmark.sh` script.
  - The script relies on `run_benchmark_gen_requests.py` to generate the requests for the benchmark.
  - The script takes `run_benchmark_endpoints.txt` containing newline-separated endpoints to benchmark.
  - Note that the **extra newline** at the end of `run_benchmark_endpoints.txt` is crucial.

```bash
$> ./run_benchmark.sh
```
