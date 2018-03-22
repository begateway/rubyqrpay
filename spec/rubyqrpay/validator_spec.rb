RSpec.describe Rubyqrpay::Validator do
  describe '.validate_payload' do
    let(:transaction_information) do
      {
        agregator_id: 'bepaid',
        merchant_account_32: {
          service_code_erip: '393931',
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
        merchant_name: 'Stroitel',
        merchant_city: 'Soligorsk',
        postal_code: '222310',
        additional_data: {
          bill_number: '--',
          mobile_number: '--',
          store_label: '--',
          loyalty_number: '***',
          reference_label: '***',
          customer_label: '--',
          terminal_label: '--',
          purpose_of_transaction: '***',
          consumer_data_request: 'AME'
        },
        merchant_information_language: {
          language_reference: 'ru',
          name_alternate: 'Строитель',
          city_alternate: 'Солигорск'
        }
      }
    end

    subject { Rubyqrpay::Validator.validate_payload(transaction_information) }

    context 'when opts is valid' do
      it 'returns valid hash' do
        expect{subject}.not_to raise_error
      end
    end

    context 'currency' do
      context 'when is not valid' do
        before { transaction_information[:currency] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /currency/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:currency) }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /currency/)
        end
      end
    end

    context 'agregator_id' do
      context 'when is not valid' do
        before { transaction_information[:agregator_id] = '^%`|' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /agregator_id/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:agregator_id) }

        context 'when merchant_account_33 exist' do
          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /agregator_id/)
          end
        end

        context 'when is missing' do
          before { transaction_information.delete(:merchant_account_33) }

          it 'returns valid hash' do
            expect{subject}.not_to raise_error
          end
        end
      end
    end

    context 'merchant_account_32' do
      context 'when is not valid' do
        before { transaction_information[:merchant_account_32] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_account_32/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:merchant_account_32) }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_account_32/)
        end
      end

      context 'service_code_erip' do
        let(:merchant_account_32) { transaction_information[:merchant_account_32] }

        context 'when is not valid' do
          before { merchant_account_32[:service_code_erip] = 555 }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /service_code_erip/)
          end
        end

        context 'when is empty' do
          before { merchant_account_32[:service_code_erip] = '' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /service_code_erip/)
          end
        end
      end

      context 'optional items' do
        let(:merchant_account_32) { transaction_information[:merchant_account_32] }

        context 'when is not valid' do
          before { merchant_account_32[:amount_edit_possibility] = 555 }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /amount_edit_possibility/)
          end
        end

        context 'when is missing' do
          before do
            merchant_account_32.delete(:payer_unique_id)
            merchant_account_32.delete(:payer_number)
            merchant_account_32.delete(:amount_edit_possibility)
          end

          it 'returns valid hash' do
            expect{subject}.not_to raise_error
          end
        end
      end

      context 'when is too long' do
        let(:merchant_account_32) { transaction_information[:merchant_account_32] }
        before do
          merchant_account_32[:service_code_erip] = '555' * 15
          merchant_account_32[:payer_unique_id] = '555' * 15
          merchant_account_32[:payer_number] = '555' * 15
        end

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_account_32/)
        end
      end
    end

    context 'merchant_account_33' do
      context 'when is not valid' do
        before { transaction_information[:merchant_account_33] = '555' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_account_33/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:merchant_account_33) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end

      context 'service_producer_code' do
        let(:merchant_account_33) { transaction_information[:merchant_account_33] }

        context 'when is not valid' do
          before { merchant_account_33[:service_producer_code] = 555 }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /service_producer_code/)
          end
        end

        context 'when is empty' do
          before { merchant_account_33[:service_producer_code] = '' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /service_producer_code/)
          end
        end
      end

      context 'optional items' do
        let(:merchant_account_33) { transaction_information[:merchant_account_33] }

        context 'when is not valid' do
          before { merchant_account_33[:order_code] = 555 }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /order_code/)
          end
        end

        context 'when is missing' do
          before do
            merchant_account_33.delete(:service_code)
            merchant_account_33.delete(:outlet)
            merchant_account_33.delete(:order_code)
          end

          it 'returns valid hash' do
            expect{subject}.not_to raise_error
          end
        end
      end

      context 'when is too long' do
        let(:merchant_account_33) { transaction_information[:merchant_account_33] }
        before do
          merchant_account_33[:service_producer_code] = '555' * 15
          merchant_account_33[:service_code] = '555' * 15
          merchant_account_33[:outlet] = '555' * 15
        end

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_account_33/)
        end
      end
    end

    context 'convenience_indicator' do
      context 'when is not valid' do
        before { transaction_information[:convenience_indicator] = 0 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /convenience_indicator/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:convenience_indicator) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end

      context 'when is eq 2' do
        before do
          transaction_information[:convenience_indicator] = 2
          transaction_information.delete(:fixed_fee)
        end

        context 'when fixed_fee is missing' do
          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /fixed_fee/)
          end
        end
      end

      context 'when is eq 3' do
        before do
          transaction_information[:convenience_indicator] = 3
          transaction_information.delete(:percentage_fee)
        end

        context 'when percentage_fee is missing' do
          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /percentage_fee/)
          end
        end
      end
    end

    context 'fixed_fee' do
      context 'when is not valid' do
        before { transaction_information[:fixed_fee] = 0.00 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /fixed_fee/)
        end
      end
    end

    context 'percentage_fee' do
      context 'when is not valid' do
        before { transaction_information[:percentage_fee] = 100.00 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /percentage_fee/)
        end
      end
    end

    context 'merchant_category_code' do
      context 'when is not valid' do
        before { transaction_information[:merchant_category_code] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_category_code/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:merchant_category_code) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end
    end

    context 'amount' do
      context 'when is not valid' do
        before { transaction_information[:amount] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /amount/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:amount) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end
    end

    context 'country' do
      context 'when is not valid' do
        before { transaction_information[:country] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /country/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:country) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end
    end

    context 'name/city/postal_code' do
      context 'when type is not valid' do
        before { transaction_information[:merchant_name] = 555 }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_name/)
        end
      end

      context 'when format is not valid' do
        before { transaction_information[:merchant_city] = 'Минск' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_city/)
        end
      end

      context 'when size is not valid' do
        before { transaction_information[:postal_code] = '555-555-555' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /postal_code/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:country) }
        before do
          transaction_information.delete(:merchant_name)
          transaction_information.delete(:merchant_city)
          transaction_information.delete(:postal_code)
        end

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end
    end

    context 'additional_data' do
      context 'when is not valid' do
        before { transaction_information[:additional_data] = '555' }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /additional_data/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:additional_data) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end

      context 'optional items' do
        let(:additional_data) { transaction_information[:additional_data] }

        context 'when is not valid' do
          before { additional_data[:consumer_data_request] = '555' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /consumer_data_request/)
          end
        end

        context 'when is missing' do
          before do
            additional_data.delete(:bill_number)
            additional_data.delete(:mobile_number)
            additional_data.delete(:store_label)
            additional_data.delete(:loyalty_number)
            additional_data.delete(:reference_label)
            additional_data.delete(:customer_label)
            additional_data.delete(:terminal_label)
            additional_data.delete(:purpose_of_transaction)
            additional_data.delete(:consumer_data_request)
          end

          it 'returns valid hash' do
            expect{subject}.not_to raise_error
          end
        end
      end

      context 'when is too long' do
        let(:additional_data) { transaction_information[:additional_data] }
        before do
          additional_data[:bill_number] = '555' * 8
          additional_data[:mobile_number] = '555' * 8
          additional_data[:store_label] = '555' * 8
          additional_data[:loyalty_number] = '555' * 8
          additional_data[:reference_label] = '555' * 8
        end

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /additional_data/)
        end
      end
    end

    context 'merchant_information_language' do
      context 'when is not valid' do
        before { transaction_information[:merchant_information_language] = [] }

        it 'raises an exception' do
          expect{subject}.to raise_error(ArgumentError, /merchant_information_language/)
        end
      end

      context 'when is missing' do
        before { transaction_information.delete(:merchant_information_language) }

        it 'returns valid hash' do
          expect{subject}.not_to raise_error
        end
      end

      let(:merchant_information_language) { transaction_information[:merchant_information_language] }

      context 'required items' do
        context 'when is not valid' do
          before { merchant_information_language[:language_reference] = '55' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /language_reference/)
          end
        end

        context 'when is empty' do
          before { merchant_information_language[:name_alternate] = '' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /name_alternate/)
          end
        end
      end

      context 'optional items' do
        context 'when is not valid' do
          before { merchant_information_language[:city_alternate] = 'Minsk-is-the-capital-of-Belarus' }

          it 'raises an exception' do
            expect{subject}.to raise_error(ArgumentError, /city_alternate/)
          end
        end

        context 'when is missing' do
          before { merchant_information_language.delete(:city_alternate) }

          it 'returns valid hash' do
            expect{subject}.not_to raise_error
          end
        end
      end
    end
  end
end
