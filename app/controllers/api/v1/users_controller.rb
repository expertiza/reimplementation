class Api::V1::UsersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  def index
    users = User.all
    render json: users, status: :ok
  end

  # GET /users/:id
  def show
    user = User.find(params[:id])
    render json: user, status: :ok
  end

  # POST /users
  def create
    # Add default password for a user if the password is not provided
    params[:user][:password] ||= 'password'
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: user, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    user = User.find(params[:id])
    user.destroy
    render json: { message: "User #{user.name} with id #{params[:id]} deleted successfully!" }, status: :no_content
  end

  # GET /api/v1/users/institution/:id
  # Get all users for an institution
  def institution_users
    institution = Institution.find(params[:id])
    users = institution.users
    render json: users, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  # GET /api/v1/users/:id/managed
  # Get all users that are managed by a user
  def managed_users
    parent = User.find(params[:id])
    if parent.student?
      render json: { error: 'Students do not manage any users' }, status: :unprocessable_entity
      return
    end
    parent = User.instantiate(parent)
    users = parent.managed_users
    render json: users, status: :ok
  end

  # Get role based users
  # GET /api/v1/users/role/:name
  def role_users
    name = params[:name].split('_').map(&:capitalize).join(' ')
    role = Role.find_by(name:)
    users = role.users
    render json: users, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  # GET /search_users
  # search users by userid or name, fullname, emailid, role. If user with userid is found, result is returned.
  # Else user is searched by key. search_by can be name, fullname, emailid, role.
  def search_users
    user_id = params[:user_id]
    key = params[:key]
    search_by = params[:search_by]

    result = User.search_users(user_id, key, search_by)

    if result.present?
      # If the result is not empty, render the users as JSON
      render json: result
    else
      # If the result is empty, render a message as JSON with a not found status
      render json: { error: 'User not found or no matching results' }, status: :not_found
    end
  end
  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:id, :name, :role_id, :full_name, :email, :parent_id, :institution_id,
                                 :email_on_review, :email_on_submission, :email_on_review_of_review,
                                 :handle, :copy_of_emails, :password, :password_confirmation)
  end

  # GET /list
  # for displaying the list of users. The API provides paginated response of users
  # This list method is used to fetch the users and display them on certain criterias which are as follows: The search_by parameter accepts 'username', 'fullname' or 'email' as values.
  # If no value for search_by is passed, all the users are displayed. The 'letter' parameter indicates the value used to match the users based on the field obtained via the search_by parameter mentioned above.
  def list
    # code here
    letter = params[:letter]
    search_by = params[:search_by]
    # If search parameters present
    if letter.present? && search_by.present?
      case search_by.to_i
      when 1 # Search by username
        @paginated_users = paginate_list&.where('name LIKE ?', "%#{letter}%")
      when 2 # Search by fullname
        @paginated_users = paginate_list&.where('fullname LIKE ?', "%#{letter}%")
      when 3 # Search by email
        @paginated_users = paginate_list&.where('email LIKE ?', "%#{letter}%")
      else
        @paginated_users = paginate_list
      end
    else # Display all users if no search parameters present
      @paginated_users = paginate_list
      if @paginated_users
        puts("Not empty" + @paginated_users.to_s) else puts("Empty")
      end

    end
    render json: @paginated_users
  end

  def user_not_found
    render json: { error: "User with id #{params[:id]} not found" }, status: :not_found
  end

  def parameter_missing
    render json: { error: 'Parameter missing' }, status: :unprocessable_entity
  end
  
  # For filtering the users list with proper search and pagination.
  # This list method is used to fetch the users and display them on certain criterias which are as follows: The search_by parameter accepts 'username', 'fullname' or 'email' as values.
  # If no value for search_by is passed, all the users are displayed. The 'letter' parameter indicates the value used to match the users based on the field obtained via the search_by parameter mentioned above.
  def paginate_list
    paginate_options = { '1' => 25, '2' => 50, '3' => 100 }

    # If the above hash does not have a value for the key,
    # it means that we need to show all the users on the page
    #
    # Just a point to remember, when we use pagination, the
    # 'users' variable should be an object, not an array

    # The type of condition for the search depends on what the user has selected from the search_by dropdown
    @search_by = params[:search_by]
    @per_page = params[:per_page] || 3
    # search for corresponding users
    # users = User.search_users(role, user_id, letter, @search_by)

    # paginate
    users = if paginate_options[@per_page.to_s].nil? # displaying all - no pagination
              User.all
            else # some pagination is active - use the per_page
              User.paginate(page: params[:page], per_page: paginate_options[@per_page.to_s])
            end
    # users = User.all
    users
  end
end
