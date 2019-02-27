#!/bin/tclsh

source operations/commons/commonScripts.tcl

proc hmscript_deleteFunction { id } {
  return [hmscript_deleteElement function ID_FUNCTIONS $id ]
}

proc hmscript_editFunction { id name description } {
  return [hmscript_editElement function $id $name $description]
}

proc hmscript_newRoom { name } {
  return [hmscript_newElement function $name ID_FUNCTIONS etRoom]
}

proc hmscript_functions { flatten withState } {
  return [hmscript_elements functions ID_FUNCTIONS $flatten $withState]
}

proc hmscript_function { id flatten withState } {
  return [hmscript_element function $id etFunction $flatten $withState]
}