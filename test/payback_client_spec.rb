require 'test/payback_test_data'
require 'lib/payback_client'

describe PaybackClient do
  
  before :each do
    @payback_card = PAYBACK_TEST_CARDS[0]
    @payback_client = PaybackClient.new(PAYBACK_PARTNER_ID, PAYBACK_BRANCH_ID)
  end
  
  it "should check the current balance" do
    points_on_card = @payback_client.check_card_for_redemption(@payback_card[:card_number])
    points_on_card.should be_a(Hash)
    points_on_card.length.should == 3
    points_on_card.should have_key(:balance)
    points_on_card.should have_key(:available)
    points_on_card.should have_key(:available_for_next_redemption)
    points_on_card[:balance].should be_a(Integer)
    points_on_card[:balance].should > 0
  end
  
  it "should redeem 2 points and the current balance should change by 2 points" do
    transaction_id = rand(99999999999)    
    points_on_card_before_redeem = @payback_client.check_card_for_redemption(@payback_card[:card_number])
    balance_before_redeem = points_on_card_before_redeem[:balance]    
    @payback_client.authenticate_alternate_and_redeem(@payback_card[:card_number], 2, transaction_id, @payback_card[:zip], @payback_card[:dob])    
    points_on_card_after_redeem = @payback_client.check_card_for_redemption(@payback_card[:card_number])
    balance_after_redeem = points_on_card_after_redeem[:balance]    
    balance_after_redeem.should == balance_before_redeem - 2
  end
  
  it "should verify the card number" do
    @payback_client.card_number_valid?(@payback_card[:card_number]).should be_true
    @payback_client.card_number_valid?(@payback_card[:card_number][0..-3]+"123").should be_false
  end
  
  it "should raise an exception if an invalid card number is passed into an api-call" do
    lambda{
      @payback_client.check_card_for_redemption(@payback_card[:card_number][0..-3]+"123")
    }.should raise_error(PaybackClient::InvalidCardException)
  end
  
  it "should raise an exception if an invalid zip code is passed into an api-call" do
    transaction_id = rand(99999999999)    
    lambda{
      @payback_client.authenticate_alternate_and_redeem(@payback_card[:card_number], 2, transaction_id, "12345", @payback_card[:dob])
    }.should raise_error(PaybackClient::AuthenticationFailedException)
  end
  
  it "should raise an exception if an invalid date of birth is passed into api-call" do
    transaction_id = rand(99999999999)    
    lambda{
      @payback_client.authenticate_alternate_and_redeem(@payback_card[:card_number], 2, transaction_id, @payback_card[:zip], "23.23.2323")
    }.should raise_error(PaybackClient::AuthenticationFailedException)
  end
  
end
