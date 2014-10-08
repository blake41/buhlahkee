class Parser

# We need to tell the parser what tokens to expect. So each type of token produced
# by our lexer needs to be declared here.

  token NUMBER
  token IDENTIFIER


  rule

    Expressions:
      Expression                  { result = Nodes.new(val)}
    ;

    SetLocal:
      IDENTIFIER '=' Expression { result = SetLocalNode.new(val[0], val[2]) }
    ;

    Expression:
      Literal
      | SetLocal
    ;

    Literal:
      NUMBER                    { result = NumberNode.new(val[0]) }
    ;
end

# The final code at the bottom of this Racc file will be put as-is in the generated `Parser` class.
# You can put some code at the top (`header`) and some inside the class (`inner`).
---- header
  require_relative "lexer"
  require_relative "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code) # Tokenize the code using our lexer
    puts @tokens.inspect if show_tokens
    do_parse # Kickoff the parsing process
  end
  
  def next_token
    @tokens.shift
  end