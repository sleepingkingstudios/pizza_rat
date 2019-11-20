# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

module RSpec
  module Matchers
    alias_matcher :have_failing_result, :be_a_failing_result

    alias_matcher :have_passing_result, :be_a_passing_result

    alias_matcher :have_result, :be_a_result
  end
end
