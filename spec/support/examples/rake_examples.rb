# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples'

module Spec::Support::Examples
  module RakeExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    def self.load_tasks_once
      return if @tasks_loaded

      Rails.application.load_tasks

      @tasks_loaded = true
    end

    def self.tasks_list
      @tasks_list ||= `bundle exec rake --tasks`
    end

    shared_examples 'should list the task' \
    do |task_name, task_description, arguments: []|
      let(:tasks_list_item) { find_task_item(task_name) }
      let(:tasks_list_arguments) do
        match_data = tasks_list_prefix.match(/\[(?<args>[\w,]+)\]/)

        match_data.nil? ? [] : match_data[:args].split(',')
      end
      let(:tasks_list_description) do
        tasks_list_item.split('#')[1..-1].join('#').strip
      end
      let(:tasks_list_name) do
        tasks_list_prefix.sub(/\[[\w,]+\]/, '')
      end
      let(:tasks_list_prefix) do
        tasks_list_item
          .split('#')
          .first
          .strip
          .sub(/\Arake /, '')
      end

      def find_task_item(task_name)
        Spec::Support::Examples::RakeExamples
          .tasks_list
          .lines
          .find { |line| line =~ /rake #{task_name}( |\[)/ }
      end

      it { expect(tasks_list_item).to be_a String }

      it { expect(tasks_list_arguments).to be == arguments }

      it { expect(tasks_list_description).to be == task_description }

      it { expect(tasks_list_name).to be == task_name }
    end
  end
end
