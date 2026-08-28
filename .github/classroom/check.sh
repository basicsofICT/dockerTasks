#!/usr/bin/env bash
# Checks 15 scored tasks total, 1 point each (max 15).
# Run this from the repository root: .github/classroom/check.sh

set -Eeuo pipefail

points=0
max=15

ok()   { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }
err()  { echo "❌ $*"; }

echo "=== Docker Tasks Checker (GitHub Codespaces) ==="

# Task 1: Docker available (client + daemon reachable)
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

# Task 4: named interactive alpine container created
if docker ps -a --format '{{.Names}}' | grep -qx 'alpine-it-demo'; then
  ok "Task 4: alpine-it-demo container exists"
  points=$((points+1))
else
  err "Task 4: alpine-it-demo container not found"
fi

# Task 5: /lab/dir1 AND /lab/dir2 exist inside alpine-it-demo
if docker ps -a --format '{{.Names}}' | grep -qx 'alpine-it-demo'; then
  docker start alpine-it-demo >/dev/null 2>&1 || true
  if docker exec alpine-it-demo test -d /lab/dir1 >/dev/null 2>&1 && \
     docker exec alpine-it-demo test -d /lab/dir2 >/dev/null 2>&1; then
    ok "Task 5: /lab/dir1 and /lab/dir2 exist in alpine-it-demo"
    points=$((points+1))
  else
    err "Task 5: /lab/dir1 and/or /lab/dir2 missing in alpine-it-demo"
  fi
else
  warn "Task 5: alpine-it-demo missing (cannot check /lab/dir1, /lab/dir2)"
fi

# Task 6: outputs/ps-a.txt saved and lists alpine-it-demo
if [ -s outputs/ps-a.txt ] && grep -q 'alpine-it-demo' outputs/ps-a.txt; then
  ok "Task 6: outputs/ps-a.txt saved and lists alpine-it-demo"
  points=$((points+1))
else
  err "Task 6: outputs/ps-a.txt missing or does not list alpine-it-demo"
fi

# Task 7: static-site-2 running with host port 8888 mapped
task7_scored=0
if docker ps -a --format '{{.Names}}' | grep -qx 'static-site-2'; then
  docker start static-site-2 >/dev/null 2>&1 || true
  if [ "$(docker inspect -f '{{.State.Running}}' static-site-2 2>/dev/null)" = "true" ]; then
    map_line="$(docker port static-site-2 80/tcp 2>/dev/null | head -n1 || true)"
    host_port="$(echo "$map_line" | awk -F: '{print $NF}')"
    if [ "$host_port" = "8888" ]; then
      ok "Task 7: static-site-2 is running and mapped to host port 8888"
      points=$((points+1))
      task7_scored=1
    fi
  fi
fi
if [ $task7_scored -eq 0 ]; then
  err "Task 7: static-site-2 not running and/or not mapped to host port 8888"
fi

# Task 8: HTTP responds on http://127.0.0.1:8888 (or discovered mapped port)
task8_scored=0
if command -v curl >/dev/null 2>&1; then
  if curl -fsS http://127.0.0.1:8888 >/dev/null 2>&1; then
    ok "Task 8: HTTP response received on 127.0.0.1:8888"
    points=$((points+1))
    task8_scored=1
  else
    map_line="$(docker port static-site-2 80/tcp 2>/dev/null | head -n1 || true)"
    host_port="$(echo "$map_line" | awk -F: '{print $NF}')"
    if [ -n "${host_port:-}" ] && curl -fsS "http://127.0.0.1:${host_port}" >/dev/null 2>&1; then
      ok "Task 8: HTTP response received on 127.0.0.1:${host_port}"
      points=$((points+1))
      task8_scored=1
    fi
  fi
fi
if [ $task8_scored -eq 0 ]; then
  err "Task 8: No HTTP response detected from static-site-2"
fi

# Task 9: outputs/inspect-static-site-2.txt saved and contains AUTHOR env var
if [ -s outputs/inspect-static-site-2.txt ] && grep -q 'AUTHOR=' outputs/inspect-static-site-2.txt; then
  ok "Task 9: outputs/inspect-static-site-2.txt saved and contains AUTHOR env var"
  points=$((points+1))
else
  err "Task 9: outputs/inspect-static-site-2.txt missing or does not contain AUTHOR env var"
fi

# Task 10: outputs/static-site-2-logs.txt saved and not empty
if [ -s outputs/static-site-2-logs.txt ]; then
  ok "Task 10: outputs/static-site-2-logs.txt saved"
  points=$((points+1))
else
  err "Task 10: outputs/static-site-2-logs.txt missing or empty"
fi

# Task 11: outputs/images.txt saved and lists alpine, hello-world, static-site
if [ -s outputs/images.txt ] && \
   grep -q 'alpine' outputs/images.txt && \
   grep -q 'hello-world' outputs/images.txt && \
   grep -q 'static-site' outputs/images.txt; then
  ok "Task 11: outputs/images.txt saved and lists required images"
  points=$((points+1))
else
  err "Task 11: outputs/images.txt missing or does not list alpine, hello-world, static-site"
fi

# Task 12: Dockerfile exists and my-first-image was built
if [ -f Dockerfile ] && grep -qi '^FROM' Dockerfile && docker image inspect my-first-image >/dev/null 2>&1; then
  ok "Task 12: Dockerfile exists and my-first-image was built"
  points=$((points+1))
else
  err "Task 12: Dockerfile missing/invalid or my-first-image not built"
fi

# Task 13: outputs/my-first-container-output.txt saved and not empty
if [ -s outputs/my-first-container-output.txt ]; then
  ok "Task 13: outputs/my-first-container-output.txt saved"
  points=$((points+1))
else
  err "Task 13: outputs/my-first-container-output.txt missing or empty"
fi

# Task 14: data/note.txt exists and is not empty (bind mount persistence)
if [ -s data/note.txt ]; then
  ok "Task 14: data/note.txt exists (bind mount persisted data)"
  points=$((points+1))
else
  err "Task 14: data/note.txt missing or empty"
fi

# Task 15: ability to stop and remove a container (tested with a temp one)
task15_scored=0
tmpc="check-cleanup-$$"
docker run -d --name "$tmpc" alpine sh -c "sleep 60" >/dev/null 2>&1 || {
  docker pull alpine >/dev/null 2>&1 || true
  docker run -d --name "$tmpc" alpine sh -c "sleep 60" >/dev/null 2>&1 || true
}
if docker ps --format '{{.Names}}' | grep -qx "$tmpc"; then
  if docker stop "$tmpc" >/dev/null 2>&1 && docker rm "$tmpc" >/dev/null 2>&1; then
    task15_scored=1
  fi
fi
docker rm -f "$tmpc" >/dev/null 2>&1 || true
if [ $task15_scored -eq 1 ]; then
  ok "Task 15: docker stop and docker rm work"
  points=$((points+1))
else
  err "Task 15: docker stop/rm check failed"
fi

echo "----------------------------------------"
echo "SCORE: $points/$max"
