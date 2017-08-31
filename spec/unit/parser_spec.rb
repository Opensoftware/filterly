# frozen_string_literal: true

require 'spec_helper'
require 'filterly/parser'

RSpec.describe Filterly::Parser do
  subject do
    described_class
      .new(params)
  end
  let(:params) do
    {
      category_ids: [12, 34, 54],
      course_annual_id: 23,
      course_semester_id: 123
    }
  end

  describe '#filters_to_ast' do
    it 'creates ast from hash params' do
      result = subject.filters_to_ast

      expect(result.to_a).to match_array(
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
                    :op_in,
                    [:attr_name, [:category_ids, [], []]],
                    [
                      :attr_array,
                      [
                        12,
                        [
                          :attr_array,
                          [
                            34,
                            [],
                            []
                          ]
                        ],
                        [:attr_array, [54, [], []]]
                      ]
                    ]
                  ]
                ],
                [
                  :statement,
                  [
                    :and,
                    [
                      :expression,
                      [
                        :op_equal,
                        [:attr_name, [:course_annual_id, [], []]],
                        [:attr_value, [23, [], []]]
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
