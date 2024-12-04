class UpdateCourseInNotifications < ActiveRecord::Migration[7.0]
  def change
    # Remove the course_id column
    remove_column :notifications, :course_id, :bigint, if_exists: true

    add_column :notifications, :course_name, :string, null: false

    add_index :notifications, :course_name
  end
end
