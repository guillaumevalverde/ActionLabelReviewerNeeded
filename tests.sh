#!/bin/bash
set -eu

cat test.json | jq '.data | length'