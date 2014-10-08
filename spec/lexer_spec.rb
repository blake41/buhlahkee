require_relative "../lexer"
require 'pry'
require 'pry-nav'

describe 'Testing the Lexer' do
  before do
    @lexer = Lexer.new
  end
  
  it 'finds a variable' do
    result = @lexer.tokenize("x")
    expect(result.first).to eq([:IDENTIFIER, "x"])
  end

  it 'finds a number' do
    result = @lexer.tokenize("2")
    expect(result.first).to eq([:NUMBER, 2])
  end

  it "finds an equals sign" do
    result = @lexer.tokenize("=")
    expect(result.first).to eq(["=", "="])    
  end

  it "finds a variable ignores a space and then an equals sign" do
    result = @lexer.tokenize("x =")
    expect(result).to eq([[:IDENTIFIER, "x"], ["=", "="]])    
  end

  it "finds a whole assignment expression" do
    result = @lexer.tokenize("x = 2")
    expect(result).to eq([[:IDENTIFIER, "x"], ["=", "="], [:NUMBER, 2]])        
  end

end