// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener udmf.g4
grammar udmf;

// parser
udmf:
  'namespace' '=' QUOTED_STRING ';' 
  block* EOF
  ;

block:
  KEYWORD '{' pair* '}' 
  ;

pair:
  ATTRIBUTE '=' value ';'
  ;

value:
  number
  | BOOLEAN_VALUE
  | QUOTED_STRING
  ;

number
  :  HEX_NUMBER
  |  INTEGER_NUMBER
  ;

// lexer
KEYWORD:
  'linedef' | 'sidedef' | 'vertex' | 'sector' | 'thing'
  ;

HEX_NUMBER
  :   '0' 'x' HEX_DIGIT+
  ;

INTEGER_NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

BOOLEAN_VALUE
  : BOOLEAN
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') | '\\' ('"' | '\\'))* '"'
  ; 

ATTRIBUTE:
  (NUM_LETTER|'_')+
  ;

fragment NUM_LETTER
  : ('a'..'z'|'A'..'Z'|'0'..'9')
  ;

fragment HEX_DIGIT
  : ('0'..'9'|'a'..'f'|'A'..'F')
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
