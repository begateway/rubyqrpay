module Rubyqrpay
  class Parser
    class << self
      def parse_payload(payload)
        payload = URI.unescape payload
        parse_to_params payload
      end

      private

      def parse_to_params(payload)
        params  = {}
        index   = 0

        until payload[index + 4].nil?
          id    = payload[index, 2]
          size  = payload[index + 2, 2].to_i
          value = payload[index + 4, size]
          params[id] = value
          index += 4 + size
        end

        params.map do |key, value|
          if [ID_MERCHANT_INFORMATION_32,
              ID_MERCHANT_INFORMATION_33,
              ID_ADDITIONAL_DATA_FIELD,
              ID_MERCHANT_INFORMATION_LANGUAGE].include? key
            [key, parse_to_params(value)]
          else
            [key, value]
          end
        end.to_h
      end
    end
  end
end
