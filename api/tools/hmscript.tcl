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

    return [_run _script_]

  }

  proc _run { p_script } {
    upvar $p_script script
    catch {
      array set result [rega_script $script]
      return $result(STDOUT)
    } err
    return $err
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