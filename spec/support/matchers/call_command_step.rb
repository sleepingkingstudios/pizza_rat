# frozen_string_literal: true

require 'support/matchers/call_command_step_matcher'

module RSpec
  module Matchers
    def call_command_step(receiver, method_name = nil)
      Spec::Support::Matchers::CallCommandStepMatcher.new(receiver, method_name)
    end
  end
end
