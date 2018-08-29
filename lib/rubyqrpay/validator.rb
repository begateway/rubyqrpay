require 'dry-validation'
require 'money'
require 'countries'
require 'iso639'

module Rubyqrpay
  class Validator
    CONSUMER_DATA_REQUEST_PATTERN = /^(A?E?M|E?M?A|M?A?E|A?M?E|E?M?A|M?E?A)$/
    ANS_PATTERN = /^[a-zA-Z0-9!@#$&()\-`.+,\/\" *]*$/ # '*' is a specific symbol for additional_data field
    MIN_MCC = 0
    MAX_MCC = 10_000
    MIN_FIXED = 0.01
    MAX_FIXED = 9_999_999_999.99
    MIN_PERCENT = 0.01
    MAX_PERCENT = 99.99

    def self.validate_payload(opts)
      schema = Dry::Validation.Schema do
        configure do
          def self.messages
            super.merge(
              en: { errors: { valid_currency:            'currency is not valid',
                              country_code?:             'country is not valid',
                              valid_language_reference:  'language_reference is not valid',
                              agregator_id_presence:     'agregator must be filled',
                              valid_merchant_account_32: 'field is too long',
                              valid_merchant_account_33: 'field is too long',
                              valid_additional_data:     'field is too long'} }
            )
          end

          def country_code?(value)
            ISO3166::Country.find_country_by_alpha2(value)
          end
        end

        validate(valid_currency: :currency) do |currency|
          Money::Currency.find_by_iso_numeric(currency)
        end

        rule(valid_country: [:country]) do |country|
          country.filled?.then(country.country_code?)
        end

        rule(fixed_fee: [:convenience_indicator, :fixed_fee]) do |indicator, fixed|
          indicator.eql?(2).then(fixed.filled?)
        end

        rule(percentage_fee: [:convenience_indicator, :percentage_fee]) do |indicator, percentage|
          indicator.eql?(3).then(percentage.filled?)
        end

        rule(agregator_id_presence: [:agregator_id, :merchant_account_33]) do |agregator_id, merchant_account_33|
          merchant_account_33.filled?.then(agregator_id.filled?)
        end

        optional(:agregator_id).maybe(:str?, format?: ANS_PATTERN)
        required(:merchant_account_32).schema do
          required(:service_code_erip).filled(:str?)
          optional(:payer_unique_id).maybe(:str?)
          optional(:payer_number).maybe(:str?)
          optional(:amount_edit_possibility).maybe(:bool?)
        end

        optional(:merchant_account_33).schema do
          required(:service_producer_code).filled(:str?)
          optional(:service_code).maybe(:str?)
          optional(:outlet).maybe(:str?)
          optional(:order_code).maybe(:str?)
        end

        validate(valid_merchant_account_32: [:merchant_account_32]) do |merchant_account_32|
          (0..99).include? merchant_account_32.to_h.values.join.size
        end

        validate(valid_merchant_account_33: [:merchant_account_33]) do |merchant_account_33|
          (0..99).include? merchant_account_33.to_h.values.join.size
        end

        validate(valid_additional_data: [:additional_data]) do |additional_data|
          (0..99).include? additional_data.to_h.values.join.size
        end

        required(:currency).filled(:int?)
        optional(:convenience_indicator).maybe(:int?, gteq?: 1, lteq?: 3)
        optional(:fixed_fee).maybe(:float?, gteq?: MIN_FIXED, lteq?: MAX_FIXED)
        optional(:percentage_fee).maybe(:float?, gteq?: MIN_PERCENT, lteq?: MAX_PERCENT)
        optional(:merchant_category_code).maybe(:int?, gteq?: MIN_MCC, lt?: MAX_MCC)
        optional(:amount).maybe(:float?, gteq?: MIN_FIXED, lteq?: MAX_FIXED)
        optional(:country).maybe(:str?)
        optional(:merchant_name).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
        optional(:merchant_city).maybe(:str?, max_size?: 15, format?: ANS_PATTERN)
        optional(:postal_code).maybe(:str?, max_size?: 10, format?: ANS_PATTERN)

        optional(:additional_data).schema do
          optional(:bill_number).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:mobile_number).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:store_label).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:loyalty_number).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:reference_label).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:customer_label).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:terminal_label).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:purpose_of_transaction).maybe(:str?, max_size?: 25, format?: ANS_PATTERN)
          optional(:consumer_data_request).maybe(format?: CONSUMER_DATA_REQUEST_PATTERN)
        end

        optional(:merchant_information_language).schema do
          validate(valid_language_reference: :language_reference) do |language_reference|
            Iso639[language_reference]
          end

          required(:language_reference).filled(:str?, max_size?: 2)
          required(:name_alternate).filled(:str?, max_size?: 25)
          optional(:city_alternate).maybe(:str?, max_size?: 15)
        end
      end

      result = schema.call(opts)
      if result.success?
        opts
      else
        raise ArgumentError, result.errors.first.to_s
      end
    end
  end
end
