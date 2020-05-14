// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener udmf.g4
grammar udmf;

// parser
udmf:
  'namespace' '=' QUOTED_STRING ';' 
  block* EOF
  ;

block:
  keyword '{' pair* '}' 
  ;

pair:
  keyword '=' value ';'
  ;

keyword:
  STRING
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
HEX_NUMBER
  : '0x' HEX_DIGIT+
  ;

INTEGER_NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

BOOLEAN_VALUE
  : BOOLEAN
  ;

STRING:
  ('a'..'z'|'A'..'Z'|'0'..'9'|'_')+
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') | '\\' ('"' | '\\'))* '"'
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
