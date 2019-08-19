#!/usr/bin/env bash

cd $PACKAGE

pub get
pub run test

cd -

bash tool/coverage.sh
