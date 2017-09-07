# frozen_string_literal: true

require File.expand_path('../../interpreter', __FILE__)

class Interpreter
  class Collector
    def call(param_builder)
      {
        where: [Interpreter.new(ast: param_builder.filters.to_ast).to_sql],
        order: param_builder.order.first.to_a.join(' '),
        from: param_builder.from.first,
        limit: param_builder.limit,
        offset: param_builder.offset,
        search_query: param_builder.search_query
      }
    end
  end
end
