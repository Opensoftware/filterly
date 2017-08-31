# frozen_string_literal: true

require 'spec_helper'
require 'filterly/node'
require 'examples/interpreter/to_sql/expression_factory'

RSpec.describe Interpreter::ToSql::ExpressionFactory do
  subject do
    described_class.new
  end

  describe '#visit' do
    let(:category_node) do
      Filterly::Node.new(
        :expression,
        [
          :op_in,
          Filterly::Node.new(:attr_name, [:category_ids, nil, nil]),
          Filterly::Node.new(
            :attr_array,
            [
              67,
              Filterly::Node.new(:attr_array, [32, nil, nil]),
              Filterly::Node.new(:attr_array, [34, nil, nil])
            ]
          )
        ]
      )
    end

    let(:annual_node) do
      Filterly::Node.new(
        :expression,
        [
          :op_equal,
          Filterly::Node.new(:attr_name, [:course_annuals, nil, nil]),
          Filterly::Node.new(:attr_value, [12, nil, nil])
        ]
      )
    end

    it 'returns exists query for category_ids' do
      expect(subject.call(category_node).split.join(' ')).to eql(
        <<~SQL.split.join(' ')
          EXISTS(
            SELECT TRUE FROM category_courses
            WHERE category_courses.category_id IN('67','32','34'))
            AND courses.id = category_courses.course_id
          )
        SQL
      )
    end

    it 'returns equal query for course_annuals' do
      expect(subject.call(annual_node).split.join(' ')).to eql(
        "courses.annual_id = '12'"
      )
    end
  end
end
