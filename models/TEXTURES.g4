// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener TEXTURES.g4
grammar TEXTURES;

// parser
textures:
  block* EOF
  ;

block:
  'Texture' name ',' height ',' width '{' patch '}' |
  'Flat' name ',' height ',' width '{' patch '}'
  ;

patch:
  'Patch' name ',' xoffset ',' yoffset
  ;

name:
  QUOTED_STRING
  ;

width:
  INTEGER_NUMBER
  ;
height:
  INTEGER_NUMBER
  ;
xoffset:
  INTEGER_NUMBER
  ;
yoffset:
  INTEGER_NUMBER
  ;

// lexer
INTEGER_NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

STRING:
  ('a'..'z'|'A'..'Z'|'0'..'9'|'_')+
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
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
