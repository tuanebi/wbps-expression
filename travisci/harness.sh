#!/bin/bash
export PERL5LIB=$PWD/wbps-expression

echo "Running test suite"
echo "Using $PERL5LIB"

perl $PWD/ensembl-test/scripts/runtests.pl $PWD/wbps-expression/t/
