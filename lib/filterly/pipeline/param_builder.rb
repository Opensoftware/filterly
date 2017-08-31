# frozen_string_literal: true

module Filterly
  module Pipeline
    class ParamBuilder
      attr_reader :filters, :from, :order, :params

      def initialize(filters:, from:, order:, params:)
        @filters = filters
        @from = from
        @order = order
        @params = params
      end

      def limit
        params[:limit]
      end

      def offset
        params[:offset]
      end

      def search_query
        params[:search_query]
      end

      def self.new
        super(
          filters: Filterly::Tree.initialize_with_filters,
          from: Set.new,
          order: Set.new,
          params: { limit: 10, offset: 0, search_query: nil }
        )
      end

      def append(deps)
        deps.each do |k, v|
          case k
          when :filters
            @filters.prepend_ast(Filterly::Parser.new(v).to_ast, :and)
          when :from
            @from << v
          when :order
            @order << v
          when :params
            @params = @params.merge(v)
          end
        end
      end

      alias << append
    end
  end
end
