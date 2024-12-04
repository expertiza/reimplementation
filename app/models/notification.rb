class Notification < ApplicationRecord
  # Associations
  belongs_to :course, foreign_key: :course_name, primary_key: :name
  belongs_to :user

  # Validations
  validates :subject, presence: true, length: { maximum: 255 }
  validates :description, presence: true
  validates :expiration_date, presence: true
  validate :expiration_date_cannot_be_in_the_past

  # Scopes
  scope :active, -> { where(active_flag: true) }
  scope :expired, -> { where('expiration_date < ?', Date.today) }
  scope :unread_by, ->(user) {
    joins(:course).where(courses: { id: user.assignments.pluck(:course_id) }).where(active_flag: true)
  }

  # Custom Validation for Expiration Date
  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "cannot be in the past")
    end
  end
end
