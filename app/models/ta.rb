class Ta < User
  has_many :ta_mappings, dependent: :destroy

  QUESTIONNAIRE = [['My questionnaires', 'list_mine'],
                   ['All public questionnaires', 'list_all']].freeze

  ASSIGNMENT = [['My assignments', 'list_mine'],
                ['All public assignments', 'list_all']].freeze

  def courses_assisted_with
    Course.where(id: ta_mappings.select(:course_id))
  end

  def is_instructor_or_co_ta?(questionnaire)
    return false if questionnaire.nil?

    instructor_ids = self.class.get_my_instructors(id)
    return true if instructor_ids.include?(questionnaire.instructor_id)

    co_tas = Ta.where(id: courses_assisted_with.joins(:tas).select(:id))
    co_tas.include?(Ta.find(questionnaire.instructor_id))
  end

  def list_all(object_type, user_id)
    object_type.where('instructor_id = ? OR private = 0', user_id)
  end

  def list_mine(object_type, user_id)
    if object_type.to_s == 'Assignment'
      Assignment.joins(:ta_mappings).where('ta_mappings.ta_id = ? OR assignments.instructor_id = ?', user_id, user_id)
    else
      object_type.where(instructor_id: user_id)
    end
  end

  def get(object_type, id, user_id)
    object_type.where('id = ? AND (instructor_id = ? OR private = 0)', id, user_id).first
  end

  def self.get_my_instructors(user_id)
    TaMapping.where(ta_id: user_id).pluck(:course_id).uniq.map do |course_id|
      Course.find(course_id).instructor_id
    end
  end

  def self.get_mapped_instructor_ids(user_id)
    TaMapping.where(ta_id: user_id).includes(:course).map { |mapping| mapping.course.instructor.id }
  end

  def self.get_mapped_courses(user_id)
    TaMapping.where(ta_id: user_id).pluck(:course_id).uniq
  end

  def get_instructor
    self.class.get_my_instructors(id).first
  end

  def set_instructor(new_assign)
    new_assign.instructor_id = get_instructor
    new_assign.course_id = TaMapping.find_by(ta_id: id).course_id
  end

  def assign_courses_to_assignment
    TaMapping.where(ta_id: id).pluck(:course_id)
  end

  def teaching_assistant?
    true
  end

  def self.get_user_list(user)
    courses = get_mapped_courses(user.id)
    participants = courses.flat_map { |course_id| Course.find(course_id).get_participants }
    participants.select { |participant| user.role.has_all_privileges_of?(participant.user.role) }
               .map(&:user)
  end
end