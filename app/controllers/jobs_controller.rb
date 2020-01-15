# frozen_string_literal: true

# Controller for performing CRUD actions on Jobs.
class JobsController < ResourcesController
  PERMITTED_ATTRIBUTES = %i[
    action_required
    application_active
    application_status
    company_name
    data
    notes
    source
    source_data
    time_period_id
    title
  ].freeze
  private_constant :PERMITTED_ATTRIBUTES

  private

  def find_time_periods
    resources['time_periods'] = TimePeriod::Factory.find_matching.call.value
  end

  def default_order
    { company_name: :asc }
  end

  def create_resource
    result = super

    find_time_periods unless result.success?

    result
  end

  def edit_resource
    steps do
      job = step super

      find_time_periods

      job
    end
  end

  def new_resource
    steps do
      job = step super

      find_time_periods

      job
    end
  end

  def permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  def resource
    @resource ||= Resource.new(Job)
  end

  def update_resource
    result = super

    find_time_periods unless result.success?

    result
  end
end
