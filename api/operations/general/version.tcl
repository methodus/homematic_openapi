#!/bin/tclsh

set filename "/www/addons/homer/VERSION"
set fd [open $filename r]
set version ""
if { $fd >=0 } {
  gets $fd version
  close $fd
}

set json {}

JSON::Dict::addString json version $version

httptool::response::send [JSON::Parser::toJSON $json]
