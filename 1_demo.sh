#!/usr/bin/env bash
set -eo pipefail

if ! humctl get application qhd; then
  humctl create application qhd
fi

humctl score deploy --app qhd --env development -f ./demo/score.yaml
