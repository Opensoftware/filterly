# frozen_string_literal: true

require File.expand_path('../interpreter/to_hash', __FILE__)
require File.expand_path('../interpreter/to_sql', __FILE__)

class Interpreter
  attr_reader :ast

  def initialize(ast:)
    @ast = ast
  end

  def to_hash
    Interpreter::ToHash.new.call(ast)
  end

  def to_sql
    Interpreter::ToSql.new.call(ast)
  end

  def to_ast
    ast
  end

  def to_s
    ast.to_s
  end

  def to_a
    ast.to_a
  end
end
