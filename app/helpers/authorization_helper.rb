module AuthorizationHelper
  # Determine if the currently logged-in user has the privileges of a Super-Admin
  def current_user_has_super_admin_privileges?
    current_user_has_privileges_of?('Super Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Admin (or higher)
  def current_user_has_admin_privileges?
    current_user_has_privileges_of?('Administrator')
  end

  # Determine if the currently logged-in user has the privileges of an Instructor (or higher)
  def current_user_has_instructor_privileges?
    current_user_has_privileges_of?('Instructor')
  end

  # Determine if the currently logged-in user has the privileges of a TA (or higher)
  def current_user_has_ta_privileges?
    current_user_has_privileges_of?('Teaching Assistant')
  end

  # Determine if the currently logged-in user has the privileges of a Student (or higher)
  def current_user_has_student_privileges?
    current_user_has_privileges_of?('Student')
  end

  # Determine if the currently logged-in user IS of the given role name
  # If there is no currently logged-in user simply return false
  def current_user_is_a?(role_name)
    current_user_and_role_exist? && current_user.role.name == role_name
  end

  # Determine if the current user has the passed-in id value
  def current_user_has_id?(id)
    user_logged_in? && current_user.id.eql?(id.to_i)
  end

  # Determine if there is a current user
  def user_logged_in?
    current_user.present?
  end

  private

  # Determine if the currently logged-in user has the privileges of the given role name (or higher privileges)
  def current_user_has_privileges_of?(role_name)
    current_user_and_role_exist? && current_user.role.all_privileges_of?(Role.find_by(name: role_name))
  end

  def current_user_and_role_exist?
    user_logged_in? && current_user.role.present?
  end
end
