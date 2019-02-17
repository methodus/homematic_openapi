#!/bin/tclsh
##
# json.tcl
# JSON-Parser.
##

namespace eval JSON {

  namespace eval Parser {
  
    proc fromJSON { text } {
      return [_parseObject text]
    }

    proc toJSON { job { parent "" } } {
      set json ""

      if { 0 < [string length $parent] } {
        set parentType [string index $parent end]
      } else {
        set parentType D
      }

      switch $parentType {
        A {
          set openBracket "\["
          set closeBracket "\]"
        }
        D {
          set openBracket "\{"
          set closeBracket "\}"
        }
        default {
          return -code error "Invalid container type: \"$parentType\""
        }
      }
      append json $openBracket

      set array {}

      foreach { elem value } $job {
        if {0 != [regexp "^(\[\\w]*)#(\[BSAND])" $elem key match type]} {
          switch $type {
            S { lappend array "\"$match\" : [_toString $value]" }
            B -
            N { lappend array "\"$match\" : $value" }
            A { lappend array [toJSON $value $key] }
            D { 
              set job [toJSON $value $key]
              lappend array "\"$match\" : $job" }
            default { return -code error "Invalid element type: \"$type\"" }
          }
        }
      }

      append json [join $array ","]
      append json $closeBracket

      return $json
    }

    proc _toString { str } {
      set map {
        "\"" "\\\""
        "\\" "\\\\"
        "/"  "\\/"
        "\b"  "\\b"
        "\f"  "\\f"
        "\n"  "\\n"
        "\r"  "\\r"
        "\t"  "\\t"
      }
      return "\"[string map $map $str]\""
    }

    proc _getc { p_text {mode 0} } {
      upvar $p_text text
      
      if { "-nospace" == $mode } then { set text [string trimleft $text] }
      if { ""         == $text } then { return -code error "unexpected end of text" }
      
      set c    [string index $text 0]
      set text [string range $text 1 end]

      return $c
    }

    proc _preview { p_text {mode 0} } {
      upvar $p_text text
      
      if { "-nospace" == $mode } then { set text [string trimleft $text] }
      if { ""         == $text } then { return -code error "unexpected end of text" }
      
      return [string index $text 0]
    }

    ##
    # Parst ein JSON-Object in ein assoziatives Array
    ##
    proc _parseObject { p_text } {
      upvar $p_text text
      set object { }
      set c      ","
      
      if { "\{" != [_getc text -nospace] } then {
        return -code error "\"\{\" expected"
      }
      
      if { "\}" != [_preview text -nospace] } then {
        while { "," == $c } {
          set name  [_parseString text]
          set c     [_getc text -nospace]
          set value ""    
        
          if { ":" == $c } then {
            set type [_parseType text]
            set value [_parseValue text]
            set c     [_getc text -nospace]

            lappend object $name\#$type $value
          }
        }
      } else {
        set c [_getc text -nospace]
      }
      
      if { "\}" != $c } then {
        return -code error "\"\}\" expected"
      }
      
      return $object
    }

    ##
    # Parst ein JSON-Array in eine Liste
    ##
    proc _parseArray { p_text } {
      upvar $p_text text
      set values {}
      set c      ","
      
      if { "\[" != [_getc text -nospace] } then {
        return -code error "\"\[\" expected"
      }
        
      if { "\]" != [_preview text -nospace] } then {
        while { "," == $c } {
          set type [_parseType text]
          lappend values $type [_parseValue text]
          set c [_getc text -nospace]
        }
      } else {
        set c [_getc text -nospace]
      }
      
      if { "\]" != $c } then {
        return -code error "\"\]\" expected, but \"$c\" found"
      }
      
      return $values  
    }

    ##
    # Parst einen JSON-Wert
    # ACHTUNG: Rekursion
    ##
    proc _parseValue { p_text } {
      upvar $p_text text
      set value ""
      
      switch -exact -- [_preview text -nospace] {
        "\""    { set value [_parseString text] }
        "\{"    { set value [_parseObject text] }
        "\["    { set value [_parseArray  text] }
        "n"     { set value [_parseConstant text null] }
        "t"     { set value [_parseConstant text true] }
        "f"     { set value [_parseConstant text false] }
        default { set value [_parseNumber text] }
      }
      
      return $value
    }

    proc _parseType { p_text } {
      upvar $p_text text
      set type ""

      switch -exact -- [_preview text -nospace] {
        "\""    { set type S }
        "\{"    { set type D }
        "\["    { set type A }
        "n"     { set type S }
        "t"     { set type B }
        "f"     { set type B }
        default { set type N }
      }
      
      return $type
    }

    ##
    # Parst eine Zeichenkette
    ##
    proc _parseString { p_text } {
      upvar $p_text text
      set str ""
      
      if { "\"" != [_getc text -nospace]} then {
        return -code error "\" expected"
      }
      
      while { "\"" != [set c [_getc text]] } {
        if { "\\" == $c } then {
          switch -exact -- [_getc text] {
            "\"" { set c "\"" }
            "\\" { set c "\\" }
            "/"  { set c "/"  }
            "b"  { set c "\b" }
            "f"  { set c "\f" }
            "n"  { set c "\n" }
            "r"  { set c "\r" }
            "t"  { set c "\t" }
            "u"  { set c "[_parseUnicodeChar text]" }
            default { return -code error "invaild escape code (\"\\$c\")" }
          }
        }
        append str $c
      }
      
      return $str
    }

    ##
    # Parst einen JSON-Zahlenwert
    ##
    proc _parseNumber { p_text } {
      upvar $p_text text
      set template {^-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-][0-9]+)?}
      
      if { ![regexp -- $template $text number] } then {
        return -code error "number expected"
      }

      set text [string range $text [string length $number] end]
      return $number  
    }

    ##
    # Parst eine Konstante
    ##
    proc _parseConstant { p_text const } {
      upvar $p_text text
      
      set text [string trimleft $text]
      if { 0 == [string first $const $text] } then {
        set text [string range $text [string length $const] end]
      } else {
        return -code error "\"$const\" expected"
      }
      return $const
    }

    ##
    # Parst ein Unicode-Zeichen, welches über \uXXXX angegeben wurde
    ##
    proc _parseUnicodeChar { p_text } {
      upvar $p_text text
      
      set    c [_getc text]
      append c [_getc text]
      append c [_getc text]
      append c [_getc text]
      
      return [subst "\\u$c"]
    }

  }

  namespace eval Array {

    proc _addElement { a type value } {
      upvar 1 $a arr
      lappend arr $type $value 
    }

    proc addString { a value } {
      upvar 1 $a arr
      _addElement arr S $value
    }

    proc addBoolean { a value } {
      upvar 1 $a arr
      _addElement arr B $value
    }

    proc addNumber { a value } {
      upvar 1 $a arr
      _addElement arr N $value
    }

    proc addArray { a value } {
      upvar 1 $a arr
      _addElement arr A $value
    }

    proc addDict { a value } {
      upvar 1 $a arr
      _addElement arr A $value
    }

  }

  namespace eval Dict {

    proc _addElement { j key type value } {
      upvar 1 $j job
      lappend job $key\#$type $value
    }

    proc addString { j key value } {
      upvar 1 $j job
      _addElement job $key S $value
    }

    proc addBoolean { j key value } {
      upvar 1 $j job
      _addElement job $key B $value
    }

    proc addNumber { j key value } {
      upvar 1 $j job
      _addElement job $key N $value
    }

    proc addArray { j key value } {
      upvar 1 $j job
      _addElement job $key A $value
    }

    proc addDict { j key value } {
      upvar 1 $j job
      _addElement job $key D $value
    }

  }

  proc convertList { arr types { associative 0 } } {
    set out {}
    set itype 0
    set tsize [llength $types]
    if { $associative == 1 } {
      foreach { key value } $arr {
        incr itype
        if { $itype >= $tsize} {
          set itype [expr $tsize - 1]
        }
        lappend out $key\#[lindex $types $itype] $value
      }
    } else {
      foreach { value } $arr {
        incr itype
        if { $itype >= $tsize} {
          set itype [expr $tsize - 1]
        }
        lappend out [lindex $types $itype] $value
      }
    }

    return $out
  }

}