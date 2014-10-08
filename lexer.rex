#
# sample1.rex
# lexical definition sample for rex
#
# usage
#  rex  sample1.rex  --stub
#  ruby sample1.rex.rb  sample1.c
#

class Lexer
# macro
#   BLANK         \s+
#   REM_IN        \/\*
#   REM_OUT       \*\/
#   REM           \/\/

rule

# literal
                \"[^"]*\"       { [:string, text] } # "
                \'[^']\'        { [:character, text] } # '

# skip
                {BLANK}         # no action

# numeric
                \d+             { [:NUMBER, text.to_i] }

# identifier
                \w+             { [:IDENTIFIER, text] }
# spaces
                \s
# operators
                =               { ["=", "="]}

inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end