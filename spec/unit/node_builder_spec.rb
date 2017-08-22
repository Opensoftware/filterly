# frozen_string_literal: true

require 'spec_helper'
require 'filterly/node_builder'

RSpec.describe Filterly::NodeBuilder do
  subject do
    described_class
  end

  describe '#self.build_equality_node' do
    it 'returns requested ast node' do
      result = subject.build_equality_node(attr_name: 'course_id', attr_value: 12)

      expect(result.to_a).to match_array(
        [
          :expression,
          [
            :op_equal,
            [
              :attr_name,
              [
                'course_id',
                [],
                []
              ]
            ],
            [
              :attr_value,
              [
                12,
                [],
                []
              ]
            ]
          ]
        ]
      )
    end
  end

  describe '#self.build_array_values_node' do
    it 'returns requested ast node' do
      result = subject.build_array_values_node(
        attr_name: 'course_id',
        array_of_values: [12, 1, 3, 4]
      )

      expect(result.to_a).to match_array(
        [
          :expression,
          [
            :op_in,
            [:attr_name, ['course_id', [], []]],
            [
              :attr_array, [
                nil,
                [
                  :attr_value, [
                    12,
                    [:attr_value, [1, [], []]],
                    [
                      :attr_value, [
                        3,
                        [:attr_value, [4, [], []]],
                        []
                      ]
                    ]
                  ]
                ],
                []
              ]
            ]
          ]
        ]
      )
    end
  end

  describe '#self.build_and_statement_node' do
    it 'returns and ast node' do
      left = subject.build_equality_node(attr_name: 'course_id', attr_value: 12)
      right = subject.build_equality_node(attr_name: 'semester_id', attr_value: 34)

      result = subject.build_and_statement_node(left: left, right: right)

      expect(result.to_a).to eql(
        [
          :statement,
          [
            :and,
            [
              :expression,
              [
                :op_equal,
                [:attr_name, ['course_id', [], []]],
                [:attr_value, [12, [], []]]
              ]
            ],
            [
              :expression,
              [
                :op_equal,
                [:attr_name, ['semester_id', [], []]],
                [:attr_value, [34, [], []]]
              ]
            ]
          ]
        ]
      )
    end
  end

  describe '#self.build_or_statement_node' do
    it 'returns or ast node' do
      left = subject.build_equality_node(attr_name: 'course_id', attr_value: 12)
      right = subject.build_equality_node(attr_name: 'semester_id', attr_value: 34)

      result = subject.build_or_statement_node(left: left, right: right)

      expect(result.to_a).to match_array(
        [
          :statement,
          [
            :or,
            [
              :expression,
              [
                :op_equal,
                [:attr_name, ['course_id', [], []]],
                [:attr_value, [12, [], []]]
              ]
            ],
            [
              :expression,
              [
                :op_equal,
                [:attr_name, ['semester_id', [], []]],
                [:attr_value, [34, [], []]]
              ]
            ]
          ]
        ]
      )
    end
  end

  describe '#self.build_custom_node' do
    it 'returns custom node' do
      result = subject.build_custom_node(type: 'root', args: [1, nil, nil])

      expect(result.to_a).to match_array([:root, [1, [], []]])
    end
  end

  describe 'nested statements' do
    it 'returns nested structure' do
      left = subject.build_equality_node(attr_name: 'course_id', attr_value: 12)
      right = subject.build_equality_node(attr_name: 'semester_id', attr_value: 34)

      and_stmt = subject.build_and_statement_node(left: left, right: right)
      result = subject.build_or_statement_node(left: and_stmt, right: right)

      expect(result.to_a).to match_array(
        [
          :statement,
          [
            :or,
            [
              :statement,
              [
                :and,
                [
                  :expression,
                  [
                    :op_equal,
                    [:attr_name, ['course_id', [], []]],
                    [:attr_value, [12, [], []]]
                  ]
                ],
                [
                  :expression,
                  [
                    :op_equal,
                    [:attr_name, ['semester_id', [], []]],
                    [:attr_value, [34, [], []]]
                  ]
                ]
              ]
            ],
            [
              :expression,
              [
                :op_equal,
                [:attr_name, ['semester_id', [], []]],
                [:attr_value, [34, [], []]]
              ]
            ]
          ]
        ]
      )
    end
  end
end
