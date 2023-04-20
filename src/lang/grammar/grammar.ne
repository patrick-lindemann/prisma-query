@preprocessor typescript

@builtin "string.ne"
@builtin "whitespace.ne"

# Grammar definition for the sequelize language parser
# https://nearley.js.org/
# Commands:
#  Compile: `nearleyc "./grammar.ne" -o "./grammar.ts"`
#  Generate Diagram: `nearley-railroad "./grammar.ne" -o "./grammar-diagram.html"`

@{%
import {
    root, 
    operator,
    prefixOperation,
    infixOperation,
    isOperation,
    inOperation,
    selector,
    func,
    identifier,
    array,
    listing,
    value,
    boolean,
    integer,
    float,
    string,
    join,
    nth
} from './processor';
%}

main -> _ condition _ {% root %}

condition
    -> comparison                                  {% id %}
    |  condition __ logical_operator __ comparison {% infixOperation %}
    |  not_operator __ condition                   {% prefixOperation %}

not_operator
    -> "not"i {% operator('not') %}

logical_operator
    -> "and"i {% operator('and') %}
    |  "or"i  {% operator('or') %}

comparison
    -> variable _ comparison_operator _ value                              {% infixOperation %}
    |  variable __ is_operator __ ( not_operator __ ):? (_null_ | _empty_) {% isOperation %}
    |  variable __ ( not_operator __ ):? in_operator __ array              {% inOperation %}
    |  "(" _ condition _ ")"                                               {% nth(2) %}

comparison_operator
    -> "="  {% operator('eq') %}
    |  "!=" {% operator('neq') %}
    |  "<"  {% operator('lt') %}
    |  "<=" {% operator('lte') %}
    |  ">"  {% operator('gt') %}
    |  ">=" {% operator('gte') %}
    |  "~"  {% operator('like') %}

is_operator
    -> "is"i {% operator('is') %}

in_operator
    -> "in"i {% operator('in') %}

value
    -> literal  {% id %}
    |  variable {% id %}

array
    -> "[" _ listing _ "]" {% array %}

listing
    -> null                   {% () => [] %}
    |  value                  {% (d) => d %}
    |  value _ "," _ listing  {% listing %}

literal
    -> _null_  {% value('null') %}
    |  boolean {% value('boolean') %}
    |  number  {% value('number') %}
    |  string  {% value('string') %}

variable
    -> selector {% id %}
    |  function {% id %}

selector
    -> identifier           {% selector %}
    |  identifier "." selector {% join %}

identifier
    -> [a-zA-Z_$] [a-zA-Z0-9_\-$]:* {% identifier %}

function
    -> identifier _ "(" _ listing _ ")" {% func %}

boolean
    -> "true"i  {% boolean %}
    |  "false"i {% boolean %}

number
    -> ("-"|"+"):? [0-9]:+       {% integer %}
    |  "-":? [0-9]:+ "." [0-9]:+ {% float %}

string
    -> dqstring {% string %}
    |  sqstring {% string %}

_null_
    -> "null"i {% id %}

_empty_
    -> "empty"i {% id %}