class Parking < ApplicationRecord
  belongs_to :user, optional: true
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
      self.amount = if duration <= 60
                      200
                    else
                      200 + ((duration - 60).to_f / 30).ceil * 100
                    end
    end
  end
end
