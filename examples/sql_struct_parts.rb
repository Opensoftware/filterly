# frozen_string_literal: true

class SqlStructParts
  PARTS = %w[select from joins where search_query order limit offset preload].freeze

  attr_reader :deps

  def initialize(**opts)
    @deps = opts[:deps] || {}
  end

  def with(deps)
    self.class.new(deps: initialize_dependencies(deps))
  end

  PARTS.each do |sql_part|
    define_method sql_part do
      @deps[sql_part.to_sym] || []
    end
  end

  # @api private
  def initialize_dependencies(deps)
    params = {}
    params = initialize_arrays(params, deps)
    params = initialize_constants(params, deps)
    params
  end

  # @api private
  def initialize_arrays(params, deps)
    params[:select] = select.to_a | deps[:select].to_a
    params[:from] = deps[:from].to_s
    params[:joins] = joins.to_a | deps[:joins].to_a
    params[:where] = where | deps[:where].to_a
    params
  end

  # @api private
  def initialize_constants(params, deps)
    params[:search_query] = deps[:search_query].to_s
    params[:order] = deps[:order].to_s
    params[:limit] = deps[:limit].to_i
    params[:offset] = deps[:offset].to_i
    params[:preload] = preload | deps[:preload].to_a
    params
  end

  alias << with
end
