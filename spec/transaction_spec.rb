require './transaction.rb'
require './account.rb'

describe Transaction do
  let(:checking) { Account.new(1000) }
  let(:wallet) { Account.new(0) }

  describe "invalid withdrawals" do
    describe "incorrect inflows" do
      before do
        @withdrawal = Transaction.withdraw(100).from(checking)
      end

      it "should not allow inflows greater than 100%" do
        @withdrawal.depositInto(wallet, 1.001)
        expect { @withdrawal.commit }.to raise_error InvalidTransactionError
      end

      it "should not allow inflows less than 100%" do
        @withdrawal.depositInto(wallet, 0.999)
        expect { @withdrawal.commit }.to raise_error InvalidTransactionError
      end
    end

    describe "insufficient funds" do
      before do
        @withdrawal = Transaction.withdraw(1001).from(checking)
        @withdrawal.depositInto(wallet)
      end

      it "should not allow withdrawals greater than the balance" do
        expect { @withdrawal.commit }.to raise_error InsufficientFundsError
      end
    end
  end

  describe "valid withdrawals" do
    before do
      @withdrawal = Transaction.withdraw(100)
        .from(checking)
        .depositInto(wallet)
        .commit
    end

    it "should reduce the balance of checking" do
      checking.balance.should == 900
    end

    it "should increase the balance of wallet" do
      wallet.balance.should == 100
    end
  end

end