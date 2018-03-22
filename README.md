# rubyQRpay

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubyqrpay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubyqrpay

## Usage

```ruby
transaction_information = {
  agregator_id: 'rubyqrpay',
  merchant_account_32: {
    service_code_erip: '111111',
    payer_unique_id: '12345678',
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
  merchant_name: 'Egor',
  merchant_city: 'Minsk',
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
    name_alternate: 'Егор',
    city_alternate: 'Минск'
  }
}

url = 'https://pay.raschet.by#'

payload = Rubyqrpay::Generator.generate_payload(transaction_information)
base64 = Rubyqrpay::Generator.generate_png(url, payload)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
