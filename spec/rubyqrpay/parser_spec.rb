RSpec.describe Rubyqrpay::Parser do
  describe '.parse_payload' do
    let(:payload) { "00020101021232430010by.raschet0106123456100933609575012021133250014by.epos.bepaid03031235303933540510.055802BY5911Ivan%20Ivanov6005Minsk6304179F" }

    subject { described_class.parse_payload(payload) }

    it 'returns params hash' do
      expect(subject).to eq({"00"=>"01",
                             "01"=>"12",
                             "32"=>{
                               "00"=>"by.raschet",
                               "01"=>"123456",
                               "10"=>"336095750",
                               "12"=>"11"
                             },
                             "33"=>{
                               "00"=>"by.epos.bepaid",
                               "03"=>"123"
                             },
                             "53"=>"933",
                             "54"=>"10.05",
                             "58"=>"BY",
                             "59"=>"Ivan Ivanov",
                             "60"=>"Minsk",
                             "63"=>"179F"})
    end
  end
end
