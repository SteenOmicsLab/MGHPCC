#!/bin/bash
find /tmp -name "msfragger*" -type d -exec rm -rf "{}" \; && \
find /tmp -name "timstoffiles*" -type d -exec rm -rf "{}" \; && \
find /tmp -empty -type d -delete && \
rm /tmp *.so && \
rm /tmp *.so.lck 