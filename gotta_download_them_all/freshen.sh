#!/bin/bash

for dir in ./all*/*
do
  (cd $dir && git pull)
done
