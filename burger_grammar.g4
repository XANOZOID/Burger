grammar burger_grammar;
// options { tokenVocab=ExprLexer; }



program: import_pattern* using_stat* export_stat* (signature | engine | enum_construct)* EOF;

ex_id: LSTRING | ID;
import_pattern: LCURLY ID (AS ID)? RCURLY
              | LCURLY ID (AS ID)? (COMMA ID (AS ID)?)+ RCURLY 
              ;
import_stat: IMPORT (MULT AS ID | ID | import_pattern) FROM ex_id SEMI;

literal: primitive | NEW new_block? | larray | lmap;
primitive: LBOOL | LNUM | LSTRING;
lmap: LBRACKET LSTRING FATARROW expr RBRACKET
    | LBRACKET LSTRING FATARROW expr (COMMA LSTRING FATARROW expr)+ RBRACKET;

enum_prefix: AUTO | CONST | UNIQUE;
enum_element: ID (EQ  ( call_body | literal ))? SEMI;
constructor: CONSTRUCTOR LPAREN ID COMMA ID RPAREN block;
enum_construct: enum_prefix* ENUM ID LCURLY (enum_element | constructor)* RCURLY;

using_stat: USING ex_id SEMI;
export_stat: EXPORT id_chain (FROM ex_id)?; 

sig_id: ID | ID PERIOD ID;
throw_id: (ID PERIOD)? ID PERIOD ID;
signature_extends: EXTENDS sig_id ;
signature_throws: THROWS throw_id | THROWS throw_id (COMMA throw_id)+;
signature_prefix: (INLINE | BRANCH | MOD | EXPORT | BLOCK | YIELDS)* (FUN | MET) ID;
sig_arg_id: ((THIS PERIOD)? ID | ID) (EQ primitive)?;
signature_head: signature_prefix LPAREN sig_arg_id? (COMMA sig_arg_id)* (COMMA rest)? RPAREN signature_extends? signature_throws?;
sig_tag: TAGID
       | TAGID LPAREN RPAREN
       | TAGID LPAREN primitive RPAREN
       | TAGID LPAREN primitive (COMMA primitive)* RPAREN
       ;
signature_block: LCURLY using_stat* stat_list (expr SEMI)? RCURLY;
signature: sig_tag* signature_head signature_block;

spread: SPREADREST ID;
rest: spread;

engine_tag: TAG ID SEMI;
engine: ENGINE LCURLY (signature_head SEMI | engine_tag | enum_construct)* RCURLY;

des_el_array: (ID (EQ expr)? | destructure);
des_el_obj: (ID (COLON ID)? (EQ expr)? | destructure);
destructure: LBRACKET RBRACKET
  | LBRACKET des_el_array  RBRACKET
  | LBRACKET des_el_array (COMMA des_el_array?)* RBRACKET
  | LCURLY RCURLY
  | LCURLY des_el_obj RCURLY
  | LCURLY des_el_obj (COMMA des_el_obj?)* RCURLY
  ;

stat_list: stat *;
stat: start_expr_block
    | start_expr SEMI 
    | block_expr 
    | VAR? destructure EQ expr SEMI
    | THROW ID PERIOD ID COMMA expr
    | EXIT expr SEMI
    | RETURN expr SEMI
    | YEET obj_chain SEMI
    | STATIC ID EQ expr SEMI
    ;


block: LCURLY stat_list (expr SEMI)? RCURLY; 
block_end_expr: (expr SEMI | block);
new_block: LCURLY stat_list RCURLY;

catch_group: LPAREN COMMA RPAREN
           | LPAREN (ID PERIOD)? ID PERIOD ID COMMA RPAREN 
           | LPAREN COMMA VAR ID RPAREN
           | LPAREN (ID PERIOD)? ID PERIOD ID COMMA VAR ID RPAREN
           ;

/*expressions which end in a block*/
block_expr: block
  | LOOPID? WHILE LPAREN expr RPAREN block_end_expr
  | if_expr
  | LOOPID? for_loop
  | LOOPID? for_each_loop
  | LOOPID? DO expr (WHILE | UNTIL) LPAREN expr RPAREN
  | LOOPID? FOREVER expr
  | TRY block_end_expr CATCH catch_group block_end_expr (FINALLY block_end_expr)?
  | switch_expr
  ;
 

if_start_expr: IF LPAREN expr RPAREN block_end_expr;
elseif_expr: ELSE IF LPAREN expr RPAREN block_end_expr;
if_expr: if_start_expr elseif_expr* (ELSE block_end_expr)?;

for_loop: FOR LPAREN expr? SEMI expr? SEMI expr? RPAREN block_end_expr;
for_each_loop: AWAIT? FOR LPAREN VAR ID IN ID RPAREN block_end_expr ;

sw_obj_pattern: LCURLY ID COLON (primitive | sw_obj_pattern | ID) RCURLY
              | LCURLY ID COLON (primitive | sw_obj_pattern | ID) (COMMA ID COLON (primitive | sw_obj_pattern | ID))+ RCURLY
              ;
sw_arr_pattern: UNDERSCORE
              | LBRACKET RBRACKET
              | LBRACKET (UNDERSCORE | ID | sw_obj_pattern) RBRACKET
              | LBRACKET (UNDERSCORE | ID | sw_obj_pattern) (COMMA (UNDERSCORE | ID | sw_obj_pattern))+ RBRACKET
              ;
switch_pattern: primitive | sw_obj_pattern | sw_arr_pattern;
switch_stats: (stat | FALLTHROUGH SEMI)* (expr SEMI)?;
switch_default: DEFAULT COLON switch_stats;
switch_gaurd: IF LPAREN expr RPAREN ;
switch_case: CASE switch_pattern (BAR switch_pattern)* switch_gaurd? COLON switch_stats;
switch_group: switch_case*;
switch_expr: SWITCH LPAREN expr RPAREN LCURLY switch_group switch_default? RCURLY;

eqop: MODEQ | MEQ | SEQ | DEQ | EQ | PEQ | QQEQ;
call_list: LPAREN (expr? | expr (COMMA expr)*) RPAREN;
call_body: LPAREN expr RPAREN COLON id_chain call_list
         | obj_chain COLON id_chain call_list
         | NEW? id_chain call_list;
call_expr: (ADDR? (CO | SPAWN))? call_body;

/*expressions which are allowed to start a statement*/
start_expr: call_expr
          | obj_chain eqop expr
          | VAR ID EQ expr
          | obj_chain (SSUB | PPLUS) 
          | block_expr
          | YIELD
          | AWAIT expr
          ;
start_expr_block: ID eqop block_expr
                | VAR ID EQ block_expr;

larray: LBRACKET expr? RBRACKET
      | LBRACKET expr (COMMA expr)* RBRACKET;

id_chain: ID | ID ((PERIOD | QACCESSOR) ID)*;
obj_chain: THIS (PERIOD | QACCESSOR) id_chain | id_chain | THIS;
ext_chain: (PERIOD|QACCESSOR) id_chain;

expr: (EXCLAMATION | SUB) expr
    | LPAREN expr RPAREN
    | expr (PPLUS | SSUB)
    | expr (MULT | DIV) expr
    | expr (SUB | PLUS) expr
    | expr QUESTION expr COLON expr
    | expr comparison expr
    | expr QQUESTION expr
    | start_expr
    | block_expr
    | NEW new_block?
    | expr ext_chain
    | obj_chain
    | expr LBRACKET expr RBRACKET /* dynamic accessor */
    | literal
    ;


comparison: GTHEN | LTHEN | GETHEN | LETHEN | OR | AND | EQEQ | NEQ ;
























/***************LEXER***************/
EXTENDS: 'extends';
THROWS: 'throws';
YIELDS: 'yields';
IMPORT: 'import';
AS: 'as';
FROM: 'from';

AND : '&&' ;
OR : '||' ;
BAR: '|';
EXCLAMATION : '!' ;
EQEQ: '==';
NEQ: '!=';
EQ : '=' ;
COMMA : ',' ;
SEMI : ';' ;
LPAREN : '(' ;
RPAREN : ')' ;
LCURLY : '{' ;
RCURLY : '}' ;
LBRACKET: '[';
RBRACKET: ']';
COLON: ':';
SPREADREST: '...';

LTHEN : '<';
GTHEN : '>';
GETHEN: '>=';
LETHEN: '<=';
FATARROW: '=>';

THIS: 'this';
PERIOD: '.';
VAR: 'var';
WHILE: 'while';
FOR: 'for';
IF: 'if' ;
ELSE: 'else';

PLUS: '+' ;
PPLUS: '++';
SUB: '-' ;
SSUB: '--';
MULT: '*';
DIV: '/';
MMOD: '%';
QUESTION: '?';
QQUESTION: '??';
QACCESSOR: '?.';

MEQ: '*=';
MODEQ: '%=';
SEQ: '-=';
PEQ: '+=';
DEQ: '/=';
QQEQ: '??=';

USING: 'using';

FUN: 'function';
MET: 'method';
INLINE: 'inline';
BRANCH: 'branch';
EXPORT: 'export';
MOD: 'mod';
BLOCK: 'block';
NEW: 'new';
YIELD: 'yield';
SPAWN: 'spawn';
CO: 'co';
AWAIT: 'await';
IN: 'in';
EXIT: 'exit';
RETURN: 'return';
FOREVER: 'forever';
DO: 'do';
UNTIL: 'until';
YEET: 'yeet';
STATIC: 'static';
ADDR: 'addr';
TRY: 'try';
THROW: 'throw';
CATCH: 'catch';
FINALLY: 'finally';

ENGINE: 'engine';
TAG: 'tag';
ENUM: 'enum';
CONSTRUCTOR: 'constructor';
AUTO: 'auto';
UNIQUE: 'unique';
CONST: 'const';
SWITCH: 'switch';
CASE: 'case';
FALLTHROUGH: 'fallthrough';
DEFAULT: 'default';
UNDERSCORE: '_';


LNUM: ('.' DIGIT+ | DIGIT+ ('.' DIGIT+)?);
LBOOL: 'true' | 'false';

fragment DIGIT: [0-9];
fragment NAME: [a-zA-Z_][a-zA-Z_0-9]*; 
TAGID: '@' NAME;
LOOPID: '#' [A-Z] ':';
ID: NAME ;
WS: [ \t\n\r\f]+ -> skip ;
COMMENT: '//' ~[\r\n]* -> skip;
ML_COMMENT: '/*' .*? '*/' -> skip;


LSTRING: '"' (~["\\] | ESC)* '"';
fragment
ESC: '\\\\' | '\\"';