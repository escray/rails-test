require 'rails_helper'

RSpec.describe Parking, type: :model do
  before do
    @time = Time.new(2017, 2, 21, 8, 0, 0)
  end

  describe '.validate_end_at_with_amount' do
    it 'is invalid without amount' do
      parking = Parking.new(parking_type: 'guest',
                            start_at: @time,
                            end_at: @time + 6.hours)
      expect(parking).to_not be_valid
    end

    it 'is invalid without end_at' do
      parking = Parking.new(parking_type: 'guest',
                            start_at: @time,
                            amount: 999)
      expect(parking).to_not be_valid
    end
  end

  describe '.calculate_amount' do
    it '30 min should be $2' do
      test_process('guest', 30, 200)
    end

    it '60 min should be $2' do
      test_process('guest', 60, 200)
    end

    it '61 min should be $3' do
      test_process('guest', 61, 300)
    end

    it '90 min should be $3' do
      test_process('guest', 90, 300)
    end

    it '120 min should be $4' do
      test_process('guest', 120, 400)
    end
  end

  context 'short-term' do
    it '30 mins should be $2' do
      test_process('short-term', 30, 200)
    end

    it '60 mins should be $2' do
      test_process('short-term', 60, 200)
    end

    it '61 mins should be $2.5' do
      test_process('short-term', 61, 250)
    end

    it '90 mins should be $2.5' do
      test_process('short-term', 90, 250)
    end

    it '120 mins should be $3' do
      test_process('short-term', 120, 300)
    end
  end

  def test_process(type, min, exp)
    parking = Parking.new(parking_type: type, start_at: @time, end_at: @time + min.minutes)

    unless type == 'guest'
      parking.user = User.create(email: 'test@example.com', password: '123456')
    end

    parking.calculate_amount
    expect(parking.amount).to eq(exp)
  end
end
