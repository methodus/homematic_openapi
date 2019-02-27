source operations/commons/commonScripts.tcl

proc hmscript_deleteRoom { id } {
  return [hmscript_deleteElement room ID_ROOMS $id ]
}

proc hmscript_editRoom { id name description } {
  return [hmscript_editElement room $id $name $description]
}

proc hmscript_newRoom { name } {
  return [hmscript_newElement room $name ID_ROOMS etRoom]
}

proc hmscript_rooms { flatten withState } {
  return [hmscript_elements rooms ID_ROOMS $flatten $withState]
}

proc hmscript_room { id flatten withState } {
  return [hmscript_element room $id etRoom $flatten $withState]
}