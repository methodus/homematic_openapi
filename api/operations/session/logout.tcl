#!/bin/tclsh

session_logout $cookieData(SID)

httptool::response::sendWithStatus 204 "No Content"