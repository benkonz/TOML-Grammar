grammar TomlGrammar;

/*
 * Parser Rules
 */

toml : (expression NL)+ ;

expression : key_value comment | table comment | comment ;

comment: COMMENT? ;

key_value : key '=' value ;

key : simple_key | dotted_key ;

simple_key : quoted_key | unquoted_key ;

unquoted_key : UNQUOTED_KEY ;

quoted_key :  basic_string | literal_string ;

dotted_key : simple_key ('.' simple_key)+ ;

value : string | integer | floating_point | bool | date_time | array | inline_table ;

string : basic_string | ml_basic_string | literal_string | ml_literal_string ;

basic_string : BASIC_STRING ;

ml_basic_string : BASIC_STRING ;

literal_string : LITERAL_STRING ;

ml_literal_string : LITERAL_STRING ;

integer : DEC_INT | HEX_INT | OCT_INT | BIN_INT ;

floating_point : FLOAT | INF | NAN ;

bool : BOOLEAN ;

date_time : OFFSET_DATE_TIME | LOCAL_DATE_TIME | LOCAL_DATE | LOCAL_TIME ;

array : '[' array_values? comment_or_nl ']' ;

array_values : (comment_or_nl value ',' array_values comment_or_nl) | comment_or_nl value ','? ;

comment_or_nl : (COMMENT? NL)* ;

table : standard_table | array_table ;

standard_table : '[' key ']' ;

inline_table : '{' inline_table_keyvals '}' ;

inline_table_keyvals : inline_table_keyvals_non_empty? ;

inline_table_keyvals_non_empty : key '=' value (',' inline_table_keyvals_non_empty)? ;

array_table : '[[' key ']]' ;

/*
 * Lexer Rules
 */
 
WS : [ \t]+ -> skip ;
NL : ('\r'? '\n')+ ;
COMMENT : '#' (~[\n])* ;

fragment DIGIT : [0-9] ;
fragment ALPHA : [A-Za-z] ;

BOOLEAN : 'true' | 'false' ;

fragment ESC : '\\' (["\\/bfnrt] | 'u' HEX_DIGIT | 'U' HEX_DIGIT) ;
BASIC_STRING : '"' (ESC | .)*? '"' ;

LITERAL_STRING : '\'' (.)*? '\'' ;

fragment HEX_DIGIT : [A-F] | DIGIT ;
fragment DIGIT_1_9 : [1-9] ;
fragment DIGIT_0_7 : [0-7] ;
fragment DIGIT_0_1 : [0-1] ;
DEC_INT : ('+' | '-')? DIGIT | DIGIT_1_9 (DIGIT | '_' DIGIT)+ ;
HEX_INT : '0x' HEX_DIGIT (HEX_DIGIT | '_' HEX_DIGIT)* ;
OCT_INT : '0o' DIGIT_0_7 (DIGIT_0_7 | '_' DIGIT_0_7) ;
BIN_INT : '0b' DIGIT_0_1 (DIGIT_0_1 | '_' DIGIT_0_1)* ;

UNQUOTED_KEY : (ALPHA | DIGIT | '-' | '_')+ ;

fragment EXP : 'e' DEC_INT ;
fragment ZERO_PREFIXABLE_INT : DIGIT (DIGIT | '_' DIGIT)* ;
fragment FRAC : '.' ZERO_PREFIXABLE_INT ;
FLOAT : DEC_INT (EXP | FRAC EXP?) ;
INF : 'INF' ;
NAN : 'NAN' ;

fragment YEAR : DIGIT DIGIT DIGIT DIGIT ;
fragment MONTH : DIGIT DIGIT ;
fragment DAY : DIGIT DIGIT ;
fragment DELIM : 'T' | 't' ;
fragment HOUR : DIGIT DIGIT ;
fragment MINUTE : DIGIT DIGIT ;
fragment SECOND : DIGIT DIGIT ;
fragment SECFRAC : '.' DIGIT+ ;
fragment NUMOFFSET : ('+' | '-') HOUR ':' MINUTE ;
fragment OFFSET : 'Z' | NUMOFFSET ;
fragment PARTIAL_TIME : HOUR ':' MINUTE ':' SECOND SECFRAC? ;
fragment FULL_DATE : YEAR '-' MONTH '-' DAY ;
fragment FULL_TIME : PARTIAL_TIME OFFSET ;
OFFSET_DATE_TIME : FULL_DATE DELIM FULL_TIME ;
LOCAL_DATE_TIME : FULL_DATE DELIM PARTIAL_TIME ;
LOCAL_DATE : FULL_DATE ;
LOCAL_TIME : PARTIAL_TIME ;