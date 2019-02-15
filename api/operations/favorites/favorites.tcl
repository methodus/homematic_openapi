#!/bin/tclsh

proc get_favorites {} {
  set hm_script ""
  append hm_script {

    object oFavorite;
    string sFavoriteId;
    string sFavoriteName;
    string sChannelId;

    WriteLine("{ \"favorites\" : " # '[');

    boolean bFirstFav = true;
    foreach (sFavoriteId, dom.GetObject(ID_FAVORITES).EnumUsedIDs()) {
      oFavorite = dom.GetObject(sFavoriteId);

      if (!bFirstFav) {
        WriteLine(",");
      } else {
        bFirstFav = false;
      }

      WriteLine("{");
      WriteLine("\"name\" : \"" # oFavorite.Name() # "\"," );
      WriteLine("\"id\" : \"" # sFavoriteId # "\"," );
      
      WriteLine("\"channels\" : " # '[');

      boolean bFirstChannel = true;
      foreach (sChannelId, oFavorite.EnumUsedIDs()) {
        object fav = dom.GetObject(sChannelId);

        if (!bFirstChannel) {
          WriteLine(",");
        } else {
          bFirstChannel = false;
        }

        WriteLine("{");
        WriteLine("\"name\" : \"" # fav.Name() # "\"," );
        WriteLine("\"id\" : \"" # sChannelId # "\"," );

        string favType = "UNKNOWN";
        if (fav.IsTypeOf(OT_PROGRAM)) { favType = "PROGRAM"; }
        if (fav.IsTypeOf(OT_DP))      { favType = "SYSVAR";  }
        if (fav.IsTypeOf(OT_CHANNEL)) { favType = "CHANNEL"; }
        WriteLine("\"type\" : \"" # favType # "\"," );

        string canUse = "false";
        string id;

        foreach (id, oFavorite.FavControlIDs().EnumIDs()) {
          if (id == sChannelId) { canUse = "true"; }
        }
        WriteLine("\"usable\" : " # canUse );
        WriteLine("}");
      }

      WriteLine("]");

      WriteLine("}");
    }

    WriteLine("]");
    WriteLine("}");

  }

  return [hmscript::run $hm_script]
}

proc get_favorite { id } {

}

proc create_favorite {} {
    
}

proc update_favorite { id data } {

}

proc delete_favorite { id } {

}

set output ""

catch {
  set method [httptool::request::method]
  switch $method {
    GET {
      array set params [httptool::request::parseQuery]
      if { [info exists params(id)] } {
        #set output [get_favorite $params(id)]
        set output [get_favorites]
      } else {
        set output [get_favorites]
      }
    }
  }
} err

httptool::response::send $output