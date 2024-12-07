class TaMapping < ApplicationRecord
  belongs_to :course
  belongs_to :ta, class_name: 'User', foreign_key: 'user_id'

  # Modify the existing methods to use user_id
  def self.get_course_ids(user_id)
    TaMapping.where(user_id: user_id).pluck(:course_id)
  end

  def self.get_courses(user_id)
    Course.where(id: get_course_ids(user_id))
  end
end