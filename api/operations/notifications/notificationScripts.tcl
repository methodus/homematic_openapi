#!/bin/tclsh

proc hmscript_notifications { } {
  set template {
    object oServices = dom.GetObject(ID_SERVICES);
    if( oServices ) {
      string sServiceId;

      WriteLine("{");
      WriteLine("\"notifications\" : " # '[');
      boolean bFirst=true;
      
      foreach(sServiceId, oServices.EnumIDs()){
        
        object oService = dom.GetObject( sServiceId );
        !< templateNotification >!
      }

      WriteLine("]");
      WriteLine("}");
    }	
  }

  array set vars {}
  set vars(templateNotification) [hmscript_notification_]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_notification_ { } {
  set hm_script {
    if( oService ) {
      if( oService.IsTypeOf( OT_ALARMDP ) && ( oService.AlState() == asOncoming ) ){
        
        object oTriggerDP = dom.GetObject(oService.AlTriggerDP());
        if( oTriggerDP ) {
          if (!bFirst) {
            WriteLine(",");
          } else {
            bFirst = false;
          }

          WriteLine("{");
          WriteLine("\"name\" : \"" # oTriggerDP.Name() # "\",");
          WriteLine("\"id\" : \"" # oTriggerDP.ID() # "\",");
          WriteLine("\"type\" : \"" # oTriggerDP.HssType() # "\",");
          WriteLine("\"timestamp\" : \"" # oTriggerDP.Timestamp().ToInteger() # "\"");
          WriteLine("}");
        }
      }
    }
  }

  return $hm_script
}

proc hmscript_deleteNotifications { } {
  set template {
    object oServices = dom.GetObject(ID_SERVICES);
    if( oServices ) {
      string sServiceId;

      foreach(sServiceId, oServices.EnumIDs()){
        object oService = dom.GetObject( sServiceId );
        !< templateDeleteNotification >!
      }
    }
  }

  array set vars {}
  set vars(templateDeleteNotification) [hmscript_deleteNotification_]
  set hm_script [file::processTemplate $template vars]

  return $hm_script
}

proc hmscript_deleteNotification { id } {
  set hm_script {}
  append hm_script "var sServiceId = \"$id\";\n"
  append hm_script {
    object oService;
    oService = dom.GetObject(sServiceId);

    if (OT_ALARMDP != oService.Type()) {
      string ERROR = "CODE 404 STATUS {Not found} MESSAGE {No alarm with ID '" # sServiceId # "' found}";
      quit;
    }
  }
  append hm_script [hmscript_deleteNotification_]

  return $hm_script
}

proc hmscript_deleteNotification_ { } {
  set hm_script {
    if( oService ) {
      if( oService.IsTypeOf( OT_ALARMDP )){
        
        object oAlTriggerDP = dom.GetObject( oService.AlTriggerDP() );
        if( oAlTriggerDP ) {
          if( oAlTriggerDP.Operations() & OPERATION_WRITE ) {
            oService.AlReceipt();
          }
        }
        else {
          oService.AlReceipt();
        }
      }
    }
  }

  return $hm_script
}