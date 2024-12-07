class Course < ApplicationRecord
  belongs_to :instructor, class_name: 'User', foreign_key: 'instructor_id'
  belongs_to :institution, foreign_key: 'institution_id'
  validates :name, presence: true
  validates :directory_path, presence: true
  has_many :ta_mappings, dependent: :destroy
  has_many :tas, through: :ta_mappings

  # Returns the submission directory for the course
  def path
    raise 'Path can not be created as the course must be associated with an instructor.' if instructor_id.nil?
    Rails.root + '/' + Institution.find(institution_id).name.gsub(" ", "") + '/' + User.find(instructor_id).name.gsub(" ", "") + '/' + directory_path + '/'
  end

  # Add a Teaching Assistant to the course
  def add_ta(user)
    if user.nil?
      return { success: false, message: "The user with id #{user.id} does not exist" }
    elsif TaMapping.exists?(user_id: user.id, course_id: id)
      return { success: false, message: "The user #{user.name} is already a TA for this course." }
    else
      puts("Adding new TA named ", user.name, " to the course!")
      ta_mapping = TaMapping.create(user_id: user.id, course_id: id)
      user.update(role: Role::TEACHING_ASSISTANT)
      if ta_mapping.save
        return { success: true, data: ta_mapping.slice(:course_id, :user_id) }
      else
        return { success: false, message: ta_mapping.errors }
      end
    end
  end

  # Removes Teaching Assistant from the course
  def remove_ta(ta_id)
    ta_mapping = ta_mappings.find_by(ta_id: ta_id, course_id: :id)
    return { success: false, message: "No TA mapping found for the specified course and TA" } if ta_mapping.nil?
    ta = User.find(ta_mapping.ta_id)
    ta_count = TaMapping.where(ta_id: ta_id).size - 1
    if ta_count.zero?
      ta.update(role: Role::STUDENT)
    end
    ta_mapping.destroy
    { success: true, ta_name: ta.name }
  end

  # Creates a copy of the course
  def copy_course
    new_course = dup
    new_course.directory_path += '_copy'
    new_course.name += '_copy'
    new_course.save
  end
end