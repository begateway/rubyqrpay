module Rubyqrpay
  class Parser
    NESTED_DATA_IDS = [ID_MERCHANT_INFORMATION_32,
                       ID_MERCHANT_INFORMATION_33,
                       ID_ADDITIONAL_DATA_FIELD,
                       ID_MERCHANT_INFORMATION_LANGUAGE]

    class << self
      def parse_payload(payload)
        parse_to_params(URI.unescape payload)
      end

      private

      def parse_to_params(payload)
        {}.tap do |params|
          index = 0

          until payload[index + 4].nil?
            key = payload[index, 2]
            size = payload[index + 2, 2].to_i
            value = payload[index + 4, size]

            params[key] = if NESTED_DATA_IDS.include? key
                            parse_to_params value
                          else
                            value
                          end

            index += 4 + size
          end
        end
      end
    end
  end
end
