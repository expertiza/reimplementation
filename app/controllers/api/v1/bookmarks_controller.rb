class Api::V1::BookmarksController < ApplicationController
  include AuthorizationHelper
  # ensure that action_allowed? returns true before any action
  before_action :check_action_allowed

  # Index method returns the list of JSON objects of the bookmark
  # GET on /bookmarks
  def index
    @bookmarks = Bookmark.order(:id)
    render json: @bookmarks, status: :ok and return
  end

  # Show method returns the JSON object of bookmark with id = {:id}
  # GET on /bookmarks/:id
  def show
    # Find the bookmark object
    @bookmark = Bookmark.find_by(id: params[:id])
    # Return error if bookmark is not found
    render json: { error: 'Bookmark not found' }, status: :not_found and return if @bookmark.nil?
    # Return the bookmark object
    render json: @bookmark, status: :ok
  end

  # Create method creates a bookmark and returns the JSON object of the created bookmark
  # POST on /bookmarks
  def create
    begin
      # params[:user_id] = @current_user.id
      @bookmark = Bookmark.new(bookmark_params)
      @bookmark.user_id = @current_user.id
      @bookmark.save!
      render json: @bookmark, status: :created and return
    rescue ActiveRecord::RecordInvalid
      render json: $ERROR_INFO.to_s, status: :unprocessable_entity
    end
  end

  # Update method updates the bookmark object with id - {:id} and returns the updated bookmark JSON object
  # PUT on /bookmarks/:id
  def update
    # Find the bookmark object
    @bookmark = Bookmark.find_by(id: params[:id])
    # Return error if bookmark is not found
    render json: { error: 'Bookmark not found' }, status: :not_found and return if @bookmark.nil?
    # Update the bookmark object
    if @bookmark.update(update_bookmark_params)
      render json: @bookmark, status: :ok
    else
      render json: @bookmark.errors.full_messages, status: :unprocessable_entity
    end
  end

  # Destroy method deletes the bookmark object with id- {:id}
  # DELETE on /bookmarks/:id
  def destroy
    # Find the bookmark object
    @bookmark = Bookmark.find_by(id: params[:id])
    # Return error if bookmark is not found
    render json: { error: 'Bookmark not found' }, status: :not_found and return if @bookmark.nil?
    # Delete the bookmark object
    @bookmark.destroy
  end

  # get_bookmark_rating_score method gets the bookmark rating of the bookmark object with id- {:id}
  # GET on /bookmarks/:id/bookmarkratings
  def get_bookmark_rating_score
    # Find the bookmark object
    @bookmark = Bookmark.find_by(id: params[:id])
    # Return error if bookmark is not found
    render json: { error: 'Bookmark not found' }, status: :not_found and return if @bookmark.nil?
    # Find the bookmark rating object
    @bookmark_rating = BookmarkRating.where(bookmark_id: @bookmark.id, user_id: @current_user.id).first
    render json: @bookmark_rating, status: :ok
  end

  # save_bookmark_rating_score method creates or updates the bookmark rating of the bookmark object with id- {:id}
  # POST on /bookmarks/:id/bookmarkratings
  def save_bookmark_rating_score
    # Find the bookmark object
    @bookmark = Bookmark.find_by(id: params[:id])
    # Return error if bookmark is not found
    render json: { error: 'Bookmark not found' }, status: :not_found and return if @bookmark.nil?
    # Find the bookmark rating object
    @bookmark_rating = BookmarkRating.where(bookmark_id: @bookmark.id, user_id: @current_user.id).first
    if @bookmark_rating.blank?
      @bookmark_rating = BookmarkRating.new(bookmark_id: @bookmark.id, user_id: @current_user.id, rating: params[:rating])
      @bookmark_rating.save!
    else
      @bookmark_rating.update({'rating': params[:rating].to_i})
    end
    render json: {"bookmark": @bookmark, "rating": @bookmark_rating}, status: :ok
  end

private

  def bookmark_params
    params.require(:bookmark).permit(:url, :title, :description, :topic_id, :rating, :id)
  end

  def update_bookmark_params
    params.require(:bookmark).permit(:url, :title, :description)
  end

  # This method is called before each action
  def check_action_allowed
    if not action_allowed?
      render json: { error: 'Access denied' }, status: :forbidden and return
    end
  end

  # Check if the user is allowed to perform the action
  def action_allowed?
    token = request.headers['Authorization'].split(' ').last

    # Decode the token and print the output
    decoded_token = JsonWebToken.decode(token)
    # Get the user from the decoded token
    user_id = decoded_token[:id]
    user = User.find(user_id)
    # Get the role of the user
    user_role_name = decoded_token[:role]
    user_role = Role.find_by(name: user_role_name)
    case params[:action]
    when 'list', 'index', 'show', 'get_bookmark_rating_score', 'save_bookmark_rating_score'
      # Those with student privileges and above can view the list of bookmarks
      user_role.id <= Role.find_by(name: 'Student').id
    when 'new', 'create', 'bookmark_rating'
      # Only those with student privileges can create bookmarks
      user_role.id == Role.find_by(name: 'Student').id
    when 'edit', 'update', 'destroy'
      # Get the bookmark object
      bookmark = Bookmark.find(params[:id])
      case user.role.name
        when 'Student'
            # Students cannot edit, update, delete bookmarks belonging to other students
            bookmark.user == user
        when 'Teaching Assistant'
            # edit, update, delete bookmarks can only be done by TA of the assignment
            # course has_many :tas, through: :ta_mappings
            TaMapping.exists?(ta_id: user.id, course_id: bookmark.topic.assignment.course.id)
            # bookmark.topic.assignment.course.tas.include?(user)
        when 'Instructor'
            # edit, update, delete bookmarks can only be done by instructor of the assignment
            bookmark.topic.assignment.instructor == user
        when 'Administrator'
            # edit, update, delete bookmarks can only be done by administrator who is the parent of the instructor of the assignment
            bookmark.topic.assignment.instructor.parent == user
        when 'Super Administrator'
            # edit, update, delete bookmarks can be done by super administrator
            true
        end
    end
  end
  # Previous implementation of action_allowed? method, utilized session[:user] and
  # AuthorizationHelper methods (which relied on the session) to check if the user
  # is allowed to perform the action. As the session cannot be set without the login
  # path, the method was updated to use the token from the Authorization header for
  # identifying the user and their role instead of the session. Once the login path
  # is implemented, the method can be updated to use the session again.
#   def action_allowed?
#     user = session[:user]
#     case params[:action]
#     when 'list', 'index'
#     when 'list', 'index', 'show', 'get_bookmark_rating_score'
#       # Those with student privileges and above can view the list of bookmarks
#       current_user_has_student_privileges?
#     when 'new', 'create', 'bookmark_rating', 'save_bookmark_rating_score'
#       # Those with strictly student privileges can create a new bookmark, rate a bookmark, or save a bookmark rating
#       # current_user_has_student_privileges? && !current_user_has_ta_privileges?
#       # This should work in theory, and it is cleaner!
#       user.role.student?
#     when 'edit', 'update', 'destroy'
#       # Get the bookmark object
#       bookmark = Bookmark.find(params[:id])
#       case user.role.name
#         when 'Student'
#             # edit, update, delete bookmarks can only be done by owner
#             current_user_created_bookmark_id?(params[:id])
#         when 'Teaching Assistant'
#             # edit, update, delete bookmarks can only be done by TA of the assignment
#             current_user_has_ta_mapping_for_assignment?(bookmark.topic.assignment)
#         when 'Instructor'
#             # edit, update, delete bookmarks can only be done by instructor of the assignment
#             current_user_instructs_assignment?(bookmark.topic.assignment)
#         when 'Administrator'
#             # edit, update, delete bookmarks can only be done by administrator who is the parent of the instructor of the assignment
#             user == bookmark.topic.assignment.instructor.parent
#         when 'Super Administrator'
#             # edit, update, delete bookmarks can be done by super administrator
#             true
#         end
#     end
#   end
end
