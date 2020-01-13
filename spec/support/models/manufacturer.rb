# frozen_string_literal: true

module Spec
  class Manufacturer < ActiveRecord::Base
    def self.migrate! # rubocop:disable Metrics/MethodLength
      connection.execute(
        <<~SQL
          CREATE TEMPORARY TABLE IF NOT EXISTS manufacturers
          (
            id bigint NOT NULL,
            name varchar(64) NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            founded_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL,
            parent_company_id bigint
          );

          CREATE TEMPORARY SEQUENCE IF NOT EXISTS manufacturers_id_seq
            START WITH 1
            INCREMENT BY 1
            NO MINVALUE
            NO MAXVALUE
            CACHE 1;
          ALTER SEQUENCE manufacturers_id_seq OWNED BY manufacturers.id;
          ALTER TABLE ONLY manufacturers
            ALTER COLUMN id
            SET DEFAULT nextval('manufacturers_id_seq'::regclass);
        SQL
      )
    end

    ### Associations
    belongs_to :parent_company,
      class_name: 'Spec::Manufacturer',
      inverse_of: :subsidiaries,
      optional:   true

    has_many :subsidiaries,
      class_name: 'Spec::Manufacturer',
      inverse_of: :parent_company

    ### Validations
    validates :founded_at, presence: true
    validates :name,
      presence:   true,
      uniqueness: true
  end
end
