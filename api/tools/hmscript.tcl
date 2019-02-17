#!/bin/tclsh
load tclrega.so

namespace eval hmscript {

  proc run { script { p_args - }} {
    set _script_ ""

    if { "-" != $p_args } then {
      upvar $p_args args

      foreach name [array names args] {
        append _script_ "var $name = \"[escapeString $args($name)]\";\n"
      }
    }

    append _script_ $script

    if { [catch { array set result [rega_script $_script_] } err ] } {
      return $err
    } else {
      if { [info exists result(ERROR)] && $result(ERROR) != "" } {
        return -code error $result(ERROR)
      }

      return $result(STDOUT)
    }
  }

  proc escapeString { str } {
    return [string map {
      "\'" "\\\'"
      "\"" "\\\""
      "\n" "\\n"
      "\r" "\\r"
      "\t" "\\t"
    } $str]
  }

}