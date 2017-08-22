# frozen_string_literal: true

require 'filterly/interpreter/to_hash'
require 'filterly/interpreter/to_sql'

module Filterly
  class Interpreter
    attr_reader :ast

    def initialize(ast:)
      @ast = ast
    end

    def to_hash
      Filterly::Interpreter::ToHash.new.call(ast)
    end

    def to_sql
      Filterly::Interpreter::ToSql.new.call(ast)
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
end
