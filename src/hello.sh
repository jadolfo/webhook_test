#!/bin/bash
cleanup()
{
  echo "cleaning up..."
  rm -rf /tmp
}

trap cleanup SIGTERM EXIT SIGABRT

echo "Added again"
echo "Added"

