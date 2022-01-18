require 'rubyqrpay/version'
require_relative 'validator'
require_relative 'constants'
require 'rqrcode'
require 'digest/crc16_ccitt'
require 'base64'
require 'uri'

module Rubyqrpay
  class Generator
    def self.generate_payload(opts)
      opts = Rubyqrpay::Validator.validate_payload(opts)
      unless opts.nil?
        payload = generation(opts)
        # percent_encode payload # Temporary solution to fix invalid BNB URI decode
      end
    end

    def self.generate_png(url, payload, **opts)
      opts_default = {size: size_func(url, payload).to_i, level: :l}
      qrcode = RQRCode::QRCode.new("#{url}#{payload}", level: opts[:level] || opts_default[:level])
      png = qrcode.as_png(resize_gte_to: false,
                          resize_exactly_to: false,
                          fill: 'white',
                          color: 'black',
                          size: opts[:size] || opts_default[:size],
                          border_modules: 4,
                          module_px_size: 6)
      qrcode_to_base64(png)
    end

    private

    def self.size_func(url, payload)
      x = "#{url}#{payload}".size
      K_SIZE_FUNC * x + B_SIZE_FUNC # linear function (kx + b)
    end

    def self.qrcode_to_base64(png)
      base64 = Base64.encode64(png.to_s)
      base64.split("\n").join
    end

    def self.generation(opts)
      payload_data = {
        ID_PAYLOAD_FORMAT                => PAYLOAD_FORMAT_EMV_QRCPS_MERCHANT_PRESENTED_MODE,
        ID_POI_METHOD                    => opts[:amount] ? POI_METHOD_DYNAMIC : POI_METHOD_STATIC,
        ID_MERCHANT_INFORMATION_32       => merchant_account_32_data(opts[:merchant_account_32]),
        ID_MERCHANT_INFORMATION_33       => merchant_account_33_data(opts[:agregator_id], opts[:merchant_account_33]),
        ID_MERCHANT_CATEGORY_CODE        => mcc_format(opts[:merchant_category_code]),
        ID_TRANSACTION_CURRENCY          => opts[:currency],
        ID_TRANSACTION_AMOUNT            => format_amount(opts[:amount]),
        ID_TIP_OF_CONVENIENCE_INDICATOR  => format_indicator(opts[:convenience_indicator]),
        ID_COUNTRY                       => opts[:country],
        ID_MERCHANT_NAME                 => opts[:merchant_name],
        ID_MERCHANT_CITY                 => opts[:merchant_city],
        ID_POSTAL_CODE                   => opts[:postal_code],
        ID_ADDITIONAL_DATA_FIELD         => additional_data_field(opts[:additional_data]),
        ID_MERCHANT_INFORMATION_LANGUAGE => merchant_language_data(opts[:merchant_information_language])
      }
      payload_data = convenience_indicator_case(payload_data, opts)
      payload = join_hash(payload_data)
      payload += crc(payload)
    end

    def self.merchant_account_32_data(merchant_account)
      merchant_account = {
        MERCHANT_INFORMATION_TEMPLATE_ID_GUID => GUID_PROMPTPAY_32,
        ID_SERVICE_CODE_ERIP       => merchant_account[:service_code_erip],
        ID_PAYER_UNIQUE            => merchant_account[:payer_unique_id],
        ID_PAYER_NUMBER            => merchant_account[:payer_number],
        ID_AMOUNT_EDIT_POSSIBILITY => aep_convert(merchant_account[:amount_edit_possibility])
      }
      join_hash(merchant_account)
    end

    def self.aep_convert(aep)
      if aep || aep.nil?
        AEP_DEFAULT
      else
        AEP_FALSE
      end
    end

    def self.merchant_account_33_data(agregator_id, merchant_account)
      unless agregator_id.nil?
        merchant_account ||= Hash.new
        merchant_account = {
            MERCHANT_INFORMATION_TEMPLATE_ID_GUID => "#{GUID_PROMPTPAY_33}#{agregator_id}",
            ID_SERVICE_PRODUCER_CODE => merchant_account[:service_producer_code],
            ID_SERVICE_CODE          => merchant_account[:service_code],
            ID_OUTLET                => merchant_account[:outlet],
            ID_ORDER_CODE            => merchant_account[:order_code]
          }
        join_hash(merchant_account)
      end
    end

    def self.additional_data_field(additional_data)
      additional_data ||= Hash.new
      additional_data = {
        ID_BILL_NUMBER            => additional_data[:bill_number],
        ID_MOBILE_NUMBER          => additional_data[:mobile_number],
        ID_STORE_LABEL            => additional_data[:store_label],
        ID_LOYALTY_NUMBER         => additional_data[:loyalty_number],
        ID_REFERENCE_LABEL        => additional_data[:reference_label],
        ID_CUSTOMER_LABEL         => additional_data[:customer_label],
        ID_TERMINAL_LABEL         => additional_data[:terminal_label],
        ID_PURPOSE_OF_TRANSACTION => additional_data[:purpose_of_transaction],
        ID_CONSUMER_DATA_REQUEST  => additional_data[:consumer_data_request]
      }
      join_hash(additional_data)
    end

    def self.merchant_language_data(merchant_information_language)
      merchant_information_language ||= Hash.new
      merchant_information_language = {
        ID_LANGUAGE_REFERENCE      => merchant_information_language[:language_reference],
        ID_MERCHANT_NAME_ALTERNATE => merchant_information_language[:name_alternate],
        ID_MERCHANT_CITY_ALTERNATE => merchant_information_language[:city_alternate]
      }
      join_hash(merchant_information_language)
    end

    def self.convenience_indicator_case(payload_data, opts)
      payload_data.tap do |data|
        case format_indicator(opts[:convenience_indicator])
        when CONVENIENCE_INDICATOR_FIXED
          data[ID_VALUE_OF_CONVENIENCE_FEE_FIXED] = format_amount(opts[:fixed_fee])
        when CONVENIENCE_INDICATOR_PERCENTAGE
          data[ID_VALUE_OF_CONVENIENCE_FEE_PERCENTAGE] = format_amount(opts[:percentage_fee])
        end
      end
    end

    def self.join_hash(hash)
      hash.map do |id, value|
        value = percent_encode(value.to_s).gsub(/\%.{2}/, '')
        unless value.empty?
          len = "00#{value.size}".slice(-2..-1)
          id + len + value
        end
      end.join
    end

    def self.format_amount(amount)
      "%.2f" % amount.to_f
    end

    def self.format_indicator(convenience_indicator)
      "0#{convenience_indicator}" if convenience_indicator
    end

    def self.percent_encode(str)
      URI.escape(str)
    end

    def self.crc(data)
      # === old algorithm
      # data += ID_CRC + CRC_SYMBOL_SIZE
      # x = Digest::CRC16CCITT.new
      # x.update(data)
      # ID_CRC + CRC_SYMBOL_SIZE + x.hexdigest.upcase

      # === updated algorithm
      ID_CRC + CRC_SYMBOL_SIZE + Digest::SHA256.hexdigest(data).slice(-4..-1).upcase
    end

    def self.mcc_format(mcc)
      "%.4d" % mcc unless mcc.to_i == 0
    end
  end
end
