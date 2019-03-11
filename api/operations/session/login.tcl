#!/bin/tclsh

##
# Einsprungpunkt
##

if { [catch { array set postData [httptool::request::parsePost] } error ] } {
    error [openapi::createError 400 "Bad request" "Invalid data: $error"]
}

set username ""
set password ""
if { [info exists postData(username)] != 0 } then { set username $postData(username) }
if { [info exists postData(password)] != 0 } then { set password $postData(password) }

set sid [session_login $username $password]

lappend header "Set-Cookie" "SID=$sid; Path=/; HttpOnly"

set output {}
append output "{"
append output "\"sessionId\" : \"$sid\""
append output "}"
  
httptool::response::sendWithStatusAndHeaders 200 "Ok" $header $output