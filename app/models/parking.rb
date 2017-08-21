class Parking < ApplicationRecord
  validates_presence_of :parking_type, :start_at
  validates_inclusion_of :parking_type, in: ['guest', 'short-term', 'long-term']

  validate :validate_end_at_with_amount

  def validate_end_at_with_amount
    if end_at.present? && amount.blank?
      errors.add(:amount, 'There must be amount if there is end time')
    end

    if end_at.blank? && amount.present?
      errors.add(:end_at, 'There must be end time if there is amount')
    end
  end

  def duration
    (end_at - start_at) / 60
  end

  def calculate_amount
    if amount.blank? && start_at.present? && end_at.present?
      total = 0
      if duration <= 60
        total = 200
      else
        total += 200
        left_duration = duration - 60
        total += (left_duration.to_f / 30).ceil * 100
      end
    end
    self.amount = total
  end
end
