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
    # debug
    # puts '---'
    # puts parking_type
    # puts '---'

    factor = user.present? ? 50 : 100

    if amount.blank? && start_at.present? && end_at.present?
      if parking_type == 'long-term'
        self.amount = calculate_long_term_amount
      else
        self.amount = if duration <= 60
                        200
                      else
                        200 + ((duration - 60).to_f / 30).ceil * factor
                      end
      end
    end
  end

  def calculate_long_term_amount
    if amount.blank? && start_at.present? && end_at.present?
      days = (duration / 1440).floor
      min = duration % 1440

      if min <= 360 && min > 0
        days * 1600 + 1200
      elsif min == 0
        days * 1600
      else
        (days + 1) * 1600
      end
    end
  end
end
