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

  def default_order
    { company_name: :asc }
  end

  def permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  def resource
    @resource ||= Resource.new(Job)
  end
end
