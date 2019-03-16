#!/bin/tclsh

package require http

set LOGIN_URL 127.0.0.1/login.htm

array set USER_LEVEL ""
set       USER_LEVEL(NONE)  0
set       USER_LEVEL(GUEST) 1
set       USER_LEVEL(USER)  2
set       USER_LEVEL(ADMIN) 8
set       USER_LEVEL(0)     NONE
set       USER_LEVEL(1)     GUEST
set       USER_LEVEL(2)     USER
set       USER_LEVEL(8)     ADMIN

proc session_getHttpHeader { pRequest headerName } {
  upvar $pRequest request

  set headerName [string toupper $headerName]
  array set meta $request(meta)
  foreach header [array names meta] {
    if {$headerName == [string toupper $header] } then {
      return $meta($header)
    }
  }
  
  return ""
}

proc session_login { username password } {
  global LOGIN_URL
 
  # Schritt 1: Benutzeranmeldung und Session erstellen
  set query [::http::formatQuery tbUsername $username tbPassword $password]
  set request [::http::geturl $LOGIN_URL -query $query]
  set location [session_getHttpHeader $request location]
  set code     [::http::code $request]
  ::http::cleanup $request

  if { -1 != [string first 503 $code] } then {
    error [openapi::createError 500 "Internal Server Error" "Invalid session id"]
  }

  if { ![regexp {sid=@([^@]*)@} $location dummy sid] } then {
    hmscript::run "system.ClearSessionID(\"$sid\");"
    error [openapi::createError 401 "Unauthorized" "Invalid username oder password"]
  }
  
  return $sid
}

##
# session_logout
# Schließt eine laufende Sitzung.
#
# @param sid [string] Session-Id
##
proc session_logout { sid } {
  if { [session_isValid $sid] == "true" } {
    hmscript::run "system.ClearSessionID(\"$sid\");"
  }
}

##
# session_isValid
# Prüft, ob eine Sitzung gültig ist
#
# @param  sid [string] Session-Id
# @return [bool] true, falls die Session-Id gültig ist
##
proc session_isValid { sid } {

  if { ![regexp {^[\dA-Za-z]{10}$} $sid] } {
    error [openapi::createError 401 "Unauthorized" "Invalid session id: $sid"]
  }

  set    script "var _session_id_ = \"$sid\";"
  append script {
    var result = false;
    var s  = system.GetSessionVarStr(_session_id_);
    if (s) { result = true; }
    Write(result);
  }

  set result [hmscript::run $script]

  if { $result != "true" } {
    error [openapi::createError 401 "Unauthorized" "Invalid session id: $sid"]
  }
  return
}

proc session_checkPermissions { sid level } {
  if { $level >= 0 } {
    global USER_LEVEL

    session_isValid $sid

    set hm_script "var _session_id_ = \"$sid\";"
    append hm_script {
      var upl = 0;
      if ( system.IsVar("_session_id_") )
      {
        var id = system.GetVar("_session_id_");
        var s  = system.GetSessionVarStr(id);
        if (s) { upl = s.StrValueByIndex(";", 1); }
      }

      Write(upl);
    }

    set userLevel [hmscript::run $hm_script]

    if { $USER_LEVEL($level) > $userLevel } {
      error [openapi::createError 403 "Forbidden" "Access denied"]
    }
  }

  return
}