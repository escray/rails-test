require 'rails_helper'

RSpec.describe Parking, type: :model do
  describe '.validate_end_at_with_amount' do
    it 'is invalid without amount' do
      parking = Parking.new(parking_type: 'guest',
                            start_at: Time.now - 6.hours,
                            end_at: Time.now)
      expect(parking).to_not be_valid
    end

    it 'is invalid without end_at' do
      parking = Parking.new(parking_type: 'guest',
                            start_at: Time.now - 6.hours,
                            amount: 999)
      expect(parking).to_not be_valid
    end
  end

  describe '.calculate_amount' do
    it '30 min should be $2' do
      test_process(30, 200)
    end

    it '60 min should be $2' do
      test_process(60, 200)
    end

    it '61 min should be $3' do
      test_process(61, 300)
    end

    it '90 min should be $3' do
      test_process(90, 300)
    end

    it '120 min should be $4' do
      test_process(120, 400)
    end
  end

  def test_process(min, exp)
    t = Time.now
    parking = Parking.new(parking_type: 'guest', start_at: t, end_at: t + min.minutes)
    parking.calculate_amount
    expect(parking.amount).to eq(exp)
  end
end
