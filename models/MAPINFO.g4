// set CLASSPATH=antlr-4.8-complete.jar
// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener MAPINFO.g4
grammar MAPINFO;

// parser
maps:
  (mapblock|infoblock|roundblock)* EOF
  ;

mapblock:
  'map' maplump label '{' pair* '}'
  ;

infoblock:
  'gameinfo' '{' pair* '}'
  ;

roundblock:
  'round' '{' (pair|actorblock|sectorblock)* '}'
  ;

actorblock:
  'actor' name '{' pair* '}'
  ;

sectorblock:
  'sector' uid '{' pair* '}'
  ;

pair:
  keyword '=' value (',' value)? ';'?
  ;

maplump:
  KEYWORD
  ;

name:
  KEYWORD
  ;

keyword:
  KEYWORD
  ;

label:
  QUOTED_STRING
  ;

value:
  NUMBER |
  BOOLEAN_VALUE |
  QUOTED_STRING
  ;

uid:
  NUMBER
  ;

NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

BOOLEAN_VALUE:
  BOOLEAN
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
  ;

KEYWORD:
  CHAR (CHAR|DIGIT)*
  ;

fragment AZ:
  'A'..'Z'
  ;

fragment CHAR:
  ('a'..'z'|'A'..'Z'|'_')
  ;

fragment DIGIT
  : ('0'..'9')
  ;

fragment BOOLEAN
  : ('true' | 'false')
  ;

BLOCKCOMMENT
   : '/*' .*? '*/' -> skip
   ;

LINECOMMENT
   : '//' ~ [\r\n]* -> skip
   ;

WS
   : [ \t\n\r] + -> skip
   ;