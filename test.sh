#!/bin/bash
if grep -q "Hello Jenkins" index.html; then
  echo "TEST OK"
  exit 0
else
  echo "TEST FAIL"
  exit 1
fi
