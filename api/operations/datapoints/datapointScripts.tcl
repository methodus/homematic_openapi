#!/bin/tclsh

proc hmscript_setDatapoint { id value } {
  set hm_script {}
  append hm_script "string sDPId = \"$id\";\n"
  append hm_script {
    object oDP = dom.GetObject(sDPId);
    if (oDP.TypeName() != "HSSDP") {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No datapoint with ID '" # sDPId # "' found}";
      quit;
    }
  }
  append hm_script "oDP.State('$value');\n"

  append hm_script [hmscript_dp_ 1]

  return $hm_script
}

proc hmscript_datapoints { withState } {
  set template {
    string sDPId;
    object oDP;
    WriteLine("\"datapoints\" : " # '[');
    boolean bFirst = true;
    foreach(sDPId, aDPIds) {
      oDP = dom.GetObject(sDPId);
      
      !< templateDP >!
    }
    WriteLine("]");

  }

  set vars(templateDP) [hmscript_dp_ $withState]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_datapoint { id withState } {
  set hm_script "string sDPId = \"$id\";\n"
  append hm_script {
    object oDP = dom.GetObject(sDPId);
    if (oDP.TypeName() != "HSSDP") {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No datapoint with ID '" # sDPId # "' found}";
      quit;
    }
    boolean bFirst = true;
  }

  append hm_script [hmscript_dp_ $withState]

  return $hm_script
}

proc hmscript_dp_ { withState } {

  set hm_script [hmscript::createFlag "withState" $withState]

  append hm_script {

    if(oDP) {
      string dp = oDP.Name().StrValueByIndex(".", 2);

      if( (dp != "ON_TIME") && (dp != "INHIBIT") && (dp != "CMD_RETS") && (dp != "CMD_RETL") && (dp != "CMD_SETS") && (dp != "CMD_SETL") ) {

        if (!bFirst) {
          WriteLine(",");
        } else {
          bFirst = false;
        }

        WriteLine("{");
        WriteLine("\"name\" : \"" # oDP.Name() # "\",");
        WriteLine("\"id\" : \"" # oDP.ID() # "\",");
        WriteLine("\"type\" : \"" # dp # "\",");
        if (withState) {
          WriteLine("\"state\" : \"" # oDP.State() # "\",");
        }
        WriteLine("\"value\" : \"" # oDP.Value() # "\",");
        WriteLine("\"valueType\" : \"" # oDP.ValueType() # "\",");
        WriteLine("\"valueUnit\" : \"" # oDP.ValueUnit() # "\",");
        WriteLine("\"timestamp\" : \"" # oDP.Timestamp().ToInteger() # "\",");
        WriteLine("\"operations\" : \"" # oDP.Operations() # "\"");
        WriteLine("}");
      }
    }

  }

  return $hm_script
}