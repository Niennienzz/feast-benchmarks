FROM python:3.11.13-slim AS base

# Builder Stage
FROM base AS builder

# Install uv, the Python package manager that actually works.
COPY --from=ghcr.io/astral-sh/uv:0.8.12 /uv /bin/uv
WORKDIR /app

# Copy uv files for better cache.
COPY uv.lock pyproject.toml /app/

# Install dependencies using uv.
RUN uv sync --frozen --no-dev

# Copy the rest of the application code.
COPY python/feature_repos/redis /app

# Runtime Stage.
FROM base
COPY --from=builder /app /app
WORKDIR /app

# Activate the virtual environment created by uv.
ENV PATH="/app/.venv/bin:$PATH"

# Run the Feast server.
CMD feast serve --host "0.0.0.0" --port 6566
