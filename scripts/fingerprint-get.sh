#!/bin/bash
set -euo pipefail

host=$1
port=$2

openssl s_client -connect $host:$port < /dev/null 2>/dev/null | openssl x509 -fingerprint -noout -in /dev/stdin
