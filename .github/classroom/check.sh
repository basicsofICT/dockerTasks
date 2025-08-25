#!/usr/bin/env bash
# Checks 12 tasks total:
# - Tasks 1–10 are scored, 1 point each (max 10).
# - Tasks 11–12 are pass/fail checks (0 points) to verify stop/rm.


set -Eeuo pipefail

points=0
max=10

ok()   { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
err()  { echo "❌ $*"; }

echo "=== Docker Tasks Checker (GitHub Codespaces) ==="

# Task 1: Docker available
if docker version >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  ok "Task 1: Docker engine reachable"
  points=$((points+1))
else
  err "Task 1: Docker engine NOT reachable"
fi

# Task 2: hello-world image present or used
if docker image inspect hello-world >/dev/null 2>&1 || \
   docker ps -a --format '{{.Image}}' | grep -qx 'hello-world'; then
  ok "Task 2: hello-world present/used"
  points=$((points+1))
else
  err "Task 2: hello-world not found"
fi

# Task 3: alpine image present or used
if docker image inspect alpine >/dev/null 2>&1 || \
   docker ps -a --format '{{.Image}}' | grep -qx 'alpine'; then
  ok "Task 3: alpine present/used"
  points=$((points+1))
else
  err "Task 3: alpine not found"
fi

# Task 4: interactive alpine container created (expected name: alpine-it-demo)
if docker ps -a --format '{{.Names}}' | grep -qx 'alpine-it-demo'; then
  ok "Task 4: alpine-it-demo container exists"
  points=$((points+1))
else
  err "Task 4: alpine-it-demo container not found"
fi

# Task 5: /lab/dir1 exists inside alpine-it-demo
if docker ps -a --format '{{.Names}}' | grep -qx 'alpine-it-demo'; then
  docker start alpine-it-demo >/dev/null 2>&1 || true
  if docker exec alpine-it-demo test -d /lab/dir1 >/dev/null 2>&1; then
    ok "Task 5: /lab/dir1 exists in alpine-it-demo"
    points=$((points+1))
  else
    err "Task 5: /lab/dir1 missing in alpine-it-demo"
  fi
else
  warn "Task 5: alpine-it-demo missing (cannot check /lab/dir1)"
fi

# Task 6: /lab/dir2 exists inside alpine-it-demo
if docker ps -a --format '{{.Names}}' | grep -qx 'alpine-it-demo'; then
  docker start alpine-it-demo >/dev/null 2>&1 || true
  if docker exec alpine-it-demo test -d /lab/dir2 >/dev/null 2>&1; then
    ok "Task 6: /lab/dir2 exists in alpine-it-demo"
    points=$((points+1))
  else
    err "Task 6: /lab/dir2 missing in alpine-it-demo"
  fi
else
  warn "Task 6: alpine-it-demo missing (cannot check /lab/dir2)"
fi

# Task 7: static-site-2 container is running
if docker ps -a --format '{{.Names}}' | grep -qx 'static-site-2'; then
  docker start static-site-2 >/dev/null 2>&1 || true
  if [ "$(docker inspect -f '{{.State.Running}}' static-site-2 2>/dev/null)" = "true" ]; then
    ok "Task 7: static-site-2 is running"
    points=$((points+1))
  else
    err "Task 7: static-site-2 exists but is not running"
  fi
else
  err "Task 7: static-site-2 not found"
fi

# Task 8: static-site-2 port mapping includes host 8888
task8_scored=0
if docker ps -a --format '{{.Names}}' | grep -qx 'static-site-2'; then
  map_line="$(docker port static-site-2 80/tcp 2>/dev/null | head -n1 || true)"
  host_port="$(echo "$map_line" | awk -F: '{print $NF}')"
  if [ "$host_port" = "8888" ]; then
    ok "Task 8: static-site-2 mapped to host port 8888"
    points=$((points+1))
    task8_scored=1
  fi
fi
if [ $task8_scored -eq 0 ]; then
  err "Task 8: static-site-2 not mapped to host port 8888"
fi

# Task 9: HTTP responds on http://127.0.0.1:8888 (or discovered mapped port)
task9_scored=0
if command -v curl >/dev/null 2>&1; then
  if curl -fsS http://127.0.0.1:8888 >/dev/null 2>&1; then
    ok "Task 9: HTTP response received on 127.0.0.1:8888"
    points=$((points+1))
    task9_scored=1
  else
    # fall back to discovered host port
    map_line="$(docker port static-site-2 80/tcp 2>/dev/null | head -n1 || true)"
    host_port="$(echo "$map_line" | awk -F: '{print $NF}')"
    if [ -n "${host_port:-}" ] && curl -fsS "http://127.0.0.1:${host_port}" >/dev/null 2>&1; then
      ok "Task 9: HTTP response received on 127.0.0.1:${host_port}"
      points=$((points+1))
      task9_scored=1
    fi
  fi
fi
if [ $task9_scored -eq 0 ]; then
  err "Task 9: No HTTP response detected"
fi

# Task 10: docker images command works
if docker images >/dev/null 2>&1; then
  ok "Task 10: docker images OK"
  points=$((points+1))
else
  err "Task 10: docker images failed"
fi

# Task 11 (no points): ability to stop a running container (tested with temp one)
tmpc="check-stop-$$"
docker run -d --name "$tmpc" alpine /bin/sh -c "sleep 60" >/dev/null 2>&1 || true
if docker ps --format '{{.Names}}' | grep -qx "$tmpc"; then
  if docker stop "$tmpc" >/dev/null 2>&1; then
    ok "Task 11 (check): docker stop works (tested with temp container)"
  else
    err "Task 11 (check): docker stop failed"
  fi
else
  # If temp container didn't start (no alpine?), try to pull and retry once
  docker pull alpine >/dev/null 2>&1 || true
  docker run -d --name "$tmpc" alpine /bin/sh -c "sleep 60" >/dev/null 2>&1 || true
  if docker stop "$tmpc" >/dev/null 2>&1; then
    ok "Task 11 (check): docker stop works (after pulling alpine)"
  else
    err "Task 11 (check): docker stop failed"
  fi
fi

# Task 12 (no points): ability to remove a container (the same temp one)
if docker rm "$tmpc" >/dev/null 2>&1; then
  ok "Task 12 (check): docker rm works (temp container removed)"
else
  # ensure cleanup even if previous step failed
  docker rm -f "$tmpc" >/dev/null 2>&1 || true
  err "Task 12 (check): docker rm failed"
fi

echo "----------------------------------------"
echo "SCORE: $points/$max"
