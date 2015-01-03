#!/bin/sh

wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz
tar zxvf ruby-2.1.5.tar.gz
cd ruby-2.1.5
./configure
make
make install
exit 0