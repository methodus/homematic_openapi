#!/bin/tclsh

set output {}
append output "{"
set first 1
foreach envVar [array names ::env] {
  if { $first == 1 } then { set first 0 } else { append output "," }
  append output "\"$envVar\" : \"$::env($envVar)\""
}
append output "}"

httptool::response::send $output