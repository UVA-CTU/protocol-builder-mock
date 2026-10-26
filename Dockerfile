FROM python:3.9-slim-bookworm

RUN pip install poetry
RUN useradd _gunicorn --no-create-home --user-group

# gunicorn comes from pyproject.toml, not apt.
RUN apt-get update && \
    apt-get install -y -q \
        gcc libssl-dev \
        curl postgresql-client git-core

WORKDIR /app
COPY pyproject.toml poetry.lock /app/
RUN poetry install --no-root

RUN set -xe \
  && apt-get remove -y gcc python3-dev libssl-dev \
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

COPY . /app/

# run poetry install again AFTER copying the app into the image
# otherwise it does not know what the main app module is
RUN poetry install

