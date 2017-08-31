# frozen_string_literal: true

require 'filterly'
require_relative 'interpreter/collector'
require_relative 'user_query_pipeline'

class UserPipeline
  attr_reader :params, :param_builder

  def initialize(params:, param_builder: ::Filterly::Pipeline::ParamBuilder.new)
    @params = params
    @param_builder = param_builder
  end

  def call
    build_params

    count, query = UserQueryPipeline.new(params: interpret_to_sql).call
    puts '---------- SQL COUNT query -----------'
    puts
    puts count
    puts
    puts
    puts '---------- SQL main query ------------'
    puts query
    puts
  end

  # @api private
  def build_params
    param_builder << filters
    param_builder << some_other_filters
  end

  # @api private
  def interpret_to_sql
    Interpreter::Collector.new.call(param_builder)
  end

  # @api private
  def filters
    params.to_h
  end

  def some_other_filters
    {
      filters: {
        course_ids: [12, 34, 54]
      },
      select: ['courses.new_column as new_one'],
      params: { search_query: 'adam' }
    }
  end
end

UserPipeline.new(
  params: {
    filters: {
      category_ids: [12, 34, 54],
      course_annual_id: 23,
      course_semester_id: 123
    },
    from: 'courses',
    order: { 'courses.id': 'asc' },
    params: {
      limit: 10,
      offset: 0,
      not_supported: 'omitted'
    }
  }
).call
