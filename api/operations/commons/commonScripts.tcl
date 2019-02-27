#!/bin/tclsh

source operations/channels/channelScripts.tcl

proc hmscript_deleteElement { type list id } {

  set hm_script "var sElementId = \"$id\";\n"
  append hm_script "string sType = \"$type\";\n"
  append hm_script "object oElements = dom.GetObject( $list );\n"
  append hm_script {
    if( oElements ) {
      object oElement = dom.GetObject( system.GetVar("sElementId") );
      if( oElement ) {
        if( oElements.Remove( oElement.ID() ) ) {
          if( !oElement.Unerasable() ) {
            if( !dom.DeleteObject( oElement.ID() ) ) {
              string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete " # sType # " with ID '" # sElementId # "'}";
              quit;
            } else {
              Write("success");
            }
          } else {
            string ERROR = "CODE 403 STATUS {Forbidden} MESSAGE {Cannot delete " # sType # " with ID '" # sElementId # "'}";
            quit;
          }
        } else {
          string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete " # sType # " with ID '" # sElementId # "'}";
          quit;
        }
      } else {
        string ERROR = "CODE 404 STATUS {Not found} MESSAGE {Cannot find " # sType # " with ID '" # sElementId # "'}";
        quit;
      }
    } else {
      string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot delete " # sType # " with ID '" # sElementId # "'}";
      quit;
    }
    return;
  }

  return $hm_script

}

proc hmscript_editElement { type id name description } {

  set hm_script {}
  append hm_script "string sType = \"$type\";\n"
  append hm_script "var sElementId = \"$id\";\n"
  append hm_script "var sElementName = \"$name\";\n"
  append hm_script "var sElementDesc = \"$description\";\n"
  set hm_script {
    object oElement = dom.GetObject(sElementId);
    if (oElement && oElement.TypeName() == "ENUM") {
      if ( system.IsVar("sElementName") ) {
        oElement.Name( system.GetVar("sElementName") );
      }
      if ( system.IsVar("sElementDesc") ) {
        oElement.EnumInfo( system.GetVar("sElementDesc") )
      }
      Write("success");
    } else {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No " # sType # " with ID '" # sElementId # "' found}";
      quit;
    }
    return;
  }

  return $hm_script

}

proc hmscript_newElement { type name list enumType } {

  set template {}
  append template "string sType = \"$type\";\n"
  append template "string sElementName = \"$name\";\n"
  append template "object oElements = dom.GetObject( $list );\n"
  append template "var vEnumType = $enumType;\n"
  append template {
    if( system.IsVar( "sElementName" ) ) {
      object oElement = dom.CreateObject( OT_ENUM, system.GetVar( "sElementName" ) );
      if( oElement ) {
        oElement.EnumType( vEnumType );
        boolean res = oElements.Add( oElement );
        if( !res ) {
          dom.DeleteObject( oElement.ID() );
          string ERROR = "CODE 500 STATUS {Internal Server Error} MESSAGE {Cannot add " # sType # " '" # sElementName # "'}";
          quit;
        }
        else {
          var ID = oElement.ID();
          !< templateElement >!
        }
      }
      else {
        string ERROR = "CODE 400 STATUS {Bad request} MESSAGE {" # sType # " with name '" # sElementName # "' already exists}";
        quit;
      }
    }
  }

  set vars(templateElement) [hmscript_element_ 0 0]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_elements { type list flatten withState } {

  set template {}
  append template "object oElements = dom.GetObject( $list );\n"
  append template "string sType = \"$type\";\n"
  append template {
    object oElement;
    string sElementId;
    WriteLine("{ \"" # sType # "\" : " # '[');
    boolean bFirstElement = true;
    foreach (sElementId, oElements.EnumUsedIDs()) {
      oElement = dom.GetObject(sElementId);
      if (!bFirstElement) {
        WriteLine(",");
      } else {
        bFirstElement = false;
      }
      !< templateElement >!
    }
    WriteLine("]");
    WriteLine("}");
  }

  set vars(templateElement) [hmscript_element_ $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_element { type id enumType flatten withState } {

  set hm_script {}
  append hm_script "var sElementId = \"$id\";\n"
  append hm_script "string sType = \"$type\";\n"
  append hm_script "var vEnumType = $enumType;\n"
  append hm_script {
    object oElement;
    string sElementName;

    oElement = dom.GetObject(sElementId);

    if (vEnumType != oElement.EnumType()) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No " # sType # " with ID '" # sElementId # "' found}";
      quit;
    }
  }

  append hm_script [hmscript_element_ $flatten $withState]

  return $hm_script

}

proc hmscript_element_ { flatten withState } {

  set template {

    WriteLine("{");
    WriteLine("\"name\" : \"" # oElement.Name() # "\"," );
    WriteLine("\"description\" : \"" # oElement.EnumInfo() # "\"," );
    WriteLine("\"id\" : \"" # oElement.ID() # "\"," );
    WriteLine("\"type\" : \"" # oElement.EnumType() # "\"," );

    var aChannelIds = oElement.EnumUsedIDs();
    !< templateChannels >!

    WriteLine("}");

  }

  set vars(templateChannels) [hmscript_channels $flatten $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script

}