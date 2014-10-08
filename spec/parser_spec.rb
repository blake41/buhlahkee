require_relative "../parser"
require 'pry'
require 'pry-nav'
describe 'Testing the Parser' do
  before do
    @parser = Parser.new
  end
  
  it "finds a number" do
    result = @parser.parse("2")
    expect(result).to eq(
      Nodes.new([
        NumberNode.new(2)
    ]))
  end

  it 'finds a variable' do
    result = @parser.parse("x = 2")
    expect(result).to eq(
      Nodes.new([
        SetLocalNode.new("x", NumberNode.new(2))
      ]))
  end

end