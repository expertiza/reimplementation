# app/services/permissions.rb
# Centralized permission logic for role-based access.
module Permissions
  # Determines if a user can manage courses (create or delete).
  def self.can_manage_courses?(user)
    user.role.super_administrator? || user.role.administrator? ||user.role.instructor?
  end

end