require_relative "function"
require_relative "call_frame"
require_relative "code_loader"
# literals table holds constants
# for example
# a = 2 + 7
# literals table[2,7]
# locals table [9, "a"]
# sample bytecode
# push instructions push stuff onto the stack
# the locals table keeps assignments like a register or variable value
PUSH_NUMBER 0 # 2
PUSH_NUMBER 1 # 7
# 2 and 7 now on the stack
ADD
#pops off the top two things on the stack and adds them pushing the result
# back onto the stack
SET_LOCAL 0 #pop the top thing off and push it onto the locals table
RETURN

class VM
  OPCODES = [
    :ADD,          #0
    :PUSH_LITERAL, #1 
    :PUSH_LOCAL,   #2
    :GET_LOCAL     #3 
  ]
# PUSH_LITERAL 0
# 
  def load(file)
    # parse function definitions
    @functions = CodeLoader.new(file)
    # call the main function
    self
  end

  def run
    main   = find_function(:main)
    frame = CallFrame.new(self, main)
    puts main.execute
  end

  def find_function(name)
    @functions[name]
  end

# how do i store local values when doing an assignment?
# we need to have a locals table.  when we insert into the table (SET_LOCAL)
# we should pass an operand of the index to the table
# when we get locals we should pass an idex to the table
# how do i retrieve values when doing assignment?
end



VM.new.load(ARGV.first)