# frozen_string_literal: true

require 'spec_helper'
require 'filterly/node'
require 'examples/interpreter'

RSpec.describe Interpreter do
  subject do
    described_class.new(ast: ast)
  end
  let(:ast) do
    Filterly::Node.new(
      :root,
      [
        :filters,
        Filterly::Node.new(
          :statement,
          [
            :and,
            Filterly::Node.new(
              :statement,
              [
                :or,
                Filterly::Node.new(
                  :expression,
                  [
                    :op_equal,
                    Filterly::Node.new(:attr_name, [:course_id, nil, nil]),
                    Filterly::Node.new(:attr_value, [23, nil, nil])
                  ]
                ),
                Filterly::Node.new(
                  :statement,
                  [
                    :or,
                    Filterly::Node.new(
                      :expression,
                      [
                        :op_equal,
                        Filterly::Node.new(:attr_name, [:course_id, nil, nil]),
                        Filterly::Node.new(:attr_value, [7, nil, nil])
                      ]
                    ),
                    Filterly::Node.new(
                      :expression,
                      [
                        :op_equal,
                        Filterly::Node.new(:attr_name, [:course_id, nil, nil]),
                        Filterly::Node.new(:attr_value, [56, nil, nil])
                      ]
                    )
                  ]
                )
              ]
            ),
            Filterly::Node.new(
              :statement,
              [
                :and,
                Filterly::Node.new(
                  :expression,
                  [
                    :op_equal,
                    Filterly::Node.new(:attr_name, [:annual, nil, nil]),
                    Filterly::Node.new(:attr_value, ['2017-2018', nil, nil])
                  ]
                ),
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
              ]
            )
          ]
        )
      ]
    )
  end

  describe '#to_hash' do
    it 'interprets ast to hash' do
      result = subject.to_hash
      expect(result).to eql(
        filters: [
          {
            or: [
              {
                course_id: 23
              },
              {
                or: [
                  {
                    course_id: 7
                  },
                  {
                    course_id: 56
                  }
                ]
              }
            ]
          },
          {
            annual: '2017-2018'
          },
          {
            category_ids: [67, 32, 34]
          }
        ]
      )
    end
  end

  describe '#to_sql' do
    it 'returns sql query' do
      expect(subject.to_sql.split.join(' ')).to eql(
        <<~SQL.split.join(' ')
          (course_id='23' OR (course_id='7' OR course_id='56')) AND annual='2017-2018'
          AND EXISTS(
            SELECT TRUE FROM category_courses
            WHERE category_courses.category_id IN('67','32','34')
            AND courses.id = category_courses.course_id
          )
        SQL
      )
    end
  end

  describe '#to_ast' do
    it 'returns self ast' do
      expect(subject.to_ast).to eql(ast)
    end
  end
end
