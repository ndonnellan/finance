require './transaction.rb'
require './account.rb'

describe 'transfer' do
  let(:checking) { Account.new(1000) }
  let(:wallet) { Account.new(0) }
  
  describe "transfer_all" do
    before do
      @balance_checking = checking.balance
      transfer_all from:checking, to:wallet
    end

    it "should tranfer all funds" do
      checking.balance.should == 0
    end
  end

end