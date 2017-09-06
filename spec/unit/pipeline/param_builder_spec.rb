# frozen_string_literal: true

require 'spec_helper'
require 'filterly/pipeline/param_builder'

RSpec.describe Filterly::Pipeline::ParamBuilder do
  subject do
    described_class.new
  end

  let(:new_params) do
    {
      filters: {
        category_ids: [12, 34, 54],
        course_semester_id: 123
      },
      from: 'courses',
      order: { 'courses.id': 'asc' },
      params: {
        limit: 10,
        offset: 0,
        search_query: 'adam',
        not_supported: 'omitted'
      },
      ingored_one: 'none'
    }
  end

  describe '#initialize' do
    it 'creates root node for fitlers ast tree' do
      expect(subject.filters.to_ast.to_a).to match_array([:root, [:filters, [], []]])
    end
  end

  describe '#append' do
    it 'appends filters, from, order and params while ignoring other keys' do
      subject << new_params
      subject << { filters: { course_timetable: '2017-03-03' } }
      subject << { order: { 'another_col': 'desc' } }
      subject << { params: { limit: 3 } }

      expect(subject.from).to match_array(['courses'])
      expect(subject.limit).to eql(3)
      expect(subject.offset).to eql(0)
      expect(subject.search_query).to eql('adam')

      expect(subject.order).to match_array(
        [
          { 'courses.id': 'asc' },
          { 'another_col': 'desc' }
        ]
      )

      expect(subject.filters.root_node.to_a).to match_array(
        [
          :root,
          [
            :filters,
            [
              :statement,
              [
                :and,
                [
                  :expression,
                  [
                    :op_equal,
                    [:attr_name, [:course_timetable, [], []]],
                    [:attr_value, ['2017-03-03', [], []]]
                  ]
                ],
                [
                  :statement,
                  [
                    :and,
                    [
                      :expression,
                      [
                        :op_in,
                        [:attr_name, [:category_ids, [], []]],
                        [
                          :attr_array,
                          [
                            12,
                            [:attr_array, [34, [], []]],
                            [:attr_array, [54, [], []]]
                          ]
                        ]
                      ]
                    ],
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:course_semester_id, [], []]],
                        [:attr_value, [123, [], []]]
                      ]
                    ]
                  ]
                ]
              ]
            ],
            []
          ]
        ]
      )
    end
  end
end
