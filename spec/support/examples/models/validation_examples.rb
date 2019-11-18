# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples/models'

module Spec::Support::Examples::Models
  module ValidationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    module ClassMethods
      # :nocov:
      def extract_message(maybe_hash, default)
        return default unless maybe_hash.is_a?(Hash)

        maybe_hash.fetch(:message, default)
      end

      def normalize_attribute_type(value)
        return nil if value.nil?

        return value.name.underscore if value.is_a?(Class)

        value.to_s
      end
      # :nocov:
    end

    shared_examples 'should validate the inclusion of' \
    do |attr_name, **options|
      message = options.fetch(:message, 'is not included in the list')
      values  = options.fetch(:in)

      context "when #{attr_name} is an invalid value" do
        let(:attributes) { super().merge(attr_name => Object.new) }

        it 'should have an error' do
          expect(subject).to have_errors.on(attr_name).with_message(message)
        end
      end

      values.each do |value|
        context "when #{attr_name} is #{value}" do
          let(:attributes) { super().merge(attr_name => value) }

          it 'should not have an error' do
            expect(subject).not_to have_errors.on(attr_name)
          end
        end
      end
    end

    shared_examples 'should validate the presence of' \
    do |attr_name, message: nil, type: nil|
      extend ClassMethods

      attr_type = normalize_attribute_type(type)
      message ||= "can't be blank"

      context "when #{attr_name} is nil" do
        let(:attributes) { super().merge(attr_name => nil) }

        it 'should have an error' do
          expect(subject).to have_errors.on(attr_name).with_message(message)
        end
      end

      if attr_type == 'string'
        context "when #{attr_name} is empty" do
          let(:attributes) { super().merge(attr_name => '') }

          it 'should have an error' do
            expect(subject).to have_errors.on(attr_name).with_message(message)
          end
        end
      end
    end
  end
end
