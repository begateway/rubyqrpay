RSpec.describe Rubyqrpay::Generator do
  describe '.generate_payload' do
    subject { Rubyqrpay::Generator.generate_payload(transaction_information) }

    context 'when 33th object does not exist' do
      let(:transaction_information) do
        {
          merchant_account_32: {
            service_code_erip: '123456',
            payer_unique_id: '336095750'
          },
          currency: 933,
          amount: 10.05,
          country: 'BY',
          merchant_name: 'Ivan Ivanov',
          merchant_city: 'Minsk'
        }
      end
      let(:payload) { '00020101021232430010by.raschet010612345610093360957501202115303933540510.055802BY5910IvanIvanov6005Minsk6304C25A' }

      it "returns valid payload" do
        expect(subject).to eq(payload)
      end
    end

    context 'when 33th object exists' do
      let(:transaction_information) do
        {
          merchant_account_32: {
            service_code_erip: '123456',
            payer_unique_id: '336095750'
          },
          merchant_account_33: {
            service_producer_code: '123'
          },
          currency: 933,
          amount: 10.05,
          country: 'BY',
          merchant_name: 'Ivan Ivanov',
          merchant_city: 'Minsk'
        }
      end

      context 'when agregator exists' do
        before { transaction_information[:agregator_id] = 'bepaid' }

        let(:payload) { '00020101021232430010by.raschet0106123456100933609575012021133250014by.epos.bepaid03031235303933540510.055802BY5910IvanIvanov6005Minsk63047647' }

        it 'return valid payload' do
          expect(subject).to eq(payload)
        end
      end

      context 'when agregator does not exist' do
        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError)
        end
      end

      context 'when agregator is empty' do
        before { transaction_information[:agregator_id] = '' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError)
        end
      end
    end

    context 'when example case from documentation' do
      let(:transaction_information) do
        {
          merchant_account_32: {
            service_code_erip: '393931',
            payer_unique_id: '336095750'
          },
          currency: 933,
          amount: 10.05,
          country: 'BY',
          merchant_name: 'mts',
          merchant_city: 'Belarus'
        }
      end

      let(:payload) { '00020101021232430010by.raschet010639393110093360957501202115303933540510.055802BY5903mts6007Belarus6304CA82' }

      it 'return valid payload' do
        expect(subject).to eq(payload)
      end
    end

    context 'when there is no input data' do
      let(:transaction_information) { nil }

      it 'raises an exception' do
        expect{subject}.to raise_error(NoMethodError)
      end
    end
  end

  describe '.check_sum' do
    let(:payload) { '00020101021229300012D156000000000510A93FO3230Q31280012D15600000001030812345678' +
                    '520441115802CN5914BEST TRANSPORT6007BEIJING64200002ZH0104最佳运输0202北京540523.72' +
                    '53031565502016233030412340603***0708A60086670902ME91320016A011223344998877070812345678' }
    let(:check_sum_result) { '6304628F' }

    it 'returns valid checksum' do
      expect(Rubyqrpay::Generator.check_sum(payload)).to eq(check_sum_result)
    end

    context 'when case from documentation' do
      let(:payload) { '00020132430010by.raschet010639393110093360957501202115303933540510.055802BY5903mts6007Belarus' }
      let(:check_sum_result) { '6304689C' }

      it 'returns valid checksum' do
        expect(Rubyqrpay::Generator.check_sum(payload)).to eq(check_sum_result)
      end
    end
  end

  describe '.percent_encode' do
    it "encodes non-ASCII symbols and spaces" do
      expect(Rubyqrpay::Generator.percent_encode('Hullo, ängstrom_☢')).to eq('Hullo,%20%C3%A4ngstrom_%E2%98%A2')
    end

    it "doesn't encode ASCII symbols" do
      expect(Rubyqrpay::Generator.percent_encode('Hello,world*123!')).to eq('Hello,world*123!')
    end
  end

  describe '.join_hash' do
    let(:data) { {'ID' => 'value'} }

    it "returns valid format" do
      expect(Rubyqrpay::Generator.join_hash(data)).to eq("ID#{"00#{data['ID'].size}".slice(-2..-1)}#{data['ID']}")
    end
  end

  let(:url) { 'https://pay.raschet.by#' }

  describe '.generate_png' do
    subject do
      payload = Rubyqrpay::Generator.generate_payload(transaction_information)
      Rubyqrpay::Generator.generate_png(url, payload)
    end

    context 'when payload size is maximum' do
      let(:payload) { '~' * 667 }

      subject { Rubyqrpay::Generator.generate_png(url, payload) }

      it 'does not raise an exception' do
        expect{subject}.not_to raise_error
      end
    end

    context 'when payload size is high' do
      let(:transaction_information) do
        {
          agregator_id: 'bepaid',
          merchant_account_32: {
            service_code_erip: '123456',
            payer_unique_id: '336095750',
            payer_number: '--',
            amount_edit_possibility: true,
          },
          merchant_account_33: {
            service_producer_code: '123',
            service_code: '--',
            outlet: '--',
            order_code: '--'
          },
          merchant_category_code: 2934,
          currency: 933,
          amount: 10.05,
          convenience_indicator: 1,
          fixed_fee: 0.01,
          percentage_fee: 12.0,
          country: 'BY',
          merchant_name: 'Ivan Ivanov',
          merchant_city: 'Minsk',
          postal_code: '222310',
          additional_data: {
            bill_number: '--',
            mobile_number: '--',
            store_label: "OOO \"rubyQRpay\"",
            loyalty_number: '***',
            reference_label: '***',
            customer_label: '--',
            terminal_label: '--',
            purpose_of_transaction: '***',
            consumer_data_request: 'AME'
          },
          merchant_information_language: {
            language_reference: 'ru',
            name_alternate: 'Иван Иванов',
            city_alternate: 'Минск'
          }
        }
      end

      it 'does not raise an exception' do
        expect{subject}.not_to raise_error
      end
    end

    context 'when payload size is medium' do
      let(:transaction_information) do
        {
          agregator_id: 'bepaid',
          merchant_account_32: {
            service_code_erip: '123456',
            payer_unique_id: '336095750',
            payer_number: '--',
            amount_edit_possibility: true,
          },
          merchant_account_33: {
            service_producer_code: '123',
            service_code: '--',
            outlet: '--',
            order_code: '--'
          },
          merchant_category_code: 2934,
          currency: 933,
          amount: 10.05,
          country: 'BY',
          merchant_name: 'Ivan Ivanov',
          merchant_city: 'Minsk',
          postal_code: '222310'
        }
      end

      it 'does not raise an exception' do
        expect{subject}.not_to raise_error
      end
    end

    context 'when payload size is low' do
      let(:transaction_information) do
        {
          merchant_account_32: {
            service_code_erip: '1'
          },
          currency: 933,
          country: 'BY',
          merchant_name: 'Ivan Ivanov',
          merchant_city: 'Minsk'
        }
      end

      it 'does not raise an exception' do
        expect{subject}.not_to raise_error
      end
    end
  end

  describe '.qrcode_to_base64' do
    let(:payload) { '00020101021232430010by.raschet010612345610093360957501202115303933540510.0563042ECF' }
    let(:base64) { Rubyqrpay::Generator.generate_png(url, payload) }

    subject { Rubyqrpay::Generator.generate_png(url, payload) }

    it 'returns static base64' do
      100.times { expect(subject).to eq(base64) }
    end
  end
end
