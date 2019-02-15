#!/bin/sh
mkdir -p tmp/xmlapi
cp -a xmlapi/* tmp/xmlapi
cp update_script tmp/
cp homer-api tmp/
cp VERSION tmp/
cp homer_api.conf tmp/
cd tmp
tar --owner=root --group=root --exclude=.DS_Store -czvf ../homer-api_addon-$(cat ../VERSION).tar.gz *
cd ..
rm -rf tmp
