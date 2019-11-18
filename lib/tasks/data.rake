# frozen_string_literal: true

require 'fixtures'

namespace :data do
  data_classes = %w[Job]

  namespace :load do
    desc 'Loads the data from /data/fixtures into the database'
    task fixtures: :environment do
      data_classes.each do |class_name|
        record_class = class_name.constantize

        next unless Fixtures.exist?(record_class)

        Fixtures.create(record_class)
      end
    end
  end

  desc 'Loads the data from the specified fixture directory into the database'
  task :load, %i[directory] => :environment do |_task, args|
    raise ArgumentError, "directory can't be blank" if args.directory.blank?

    data_classes.each do |class_name|
      record_class = class_name.constantize

      next unless Fixtures.exist?(record_class, environment: args.directory)

      Fixtures.create(record_class, environment: args.directory)
    end
  end
end
