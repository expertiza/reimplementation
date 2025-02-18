FactoryBot.define do
  factory :account_request do
    sequence(:username) { Faker::Internet.username }
    sequence(:email) { Faker::Internet.email }
    sequence(:full_name) { Faker::Internet.username }
    role
    institution
  end

  factory :administrator, parent: :user do
  end

  factory :answer do
    response
    question
  end

  # spec/factories.rb
  factory :assignment do
    sequence(:title) { |n| "Assignment_#{n}_#{SecureRandom.hex(4)}" }
    association :course
    association :instructor, factory: :user  # Add this line

    has_badge { false }
    enable_pair_programming { false }
    is_calibrated { false }
    staggered_deadline { false }
    # Add other attributes as needed
  end

  factory :assignment_node, parent: :node do
  end

  factory :assignment_participant do
    assignment
    user
    handle { user.name }

    # Create and associate a team for this assignment participant
    after(:create) do |participant, evaluator|
      # Create a team and add this participant to the team
      team = create(:team, assignment: participant.assignment)
      participant.update(team: team)
      team.participants << participant
    end
  end

  factory :assignment_questionnaire do
    assignment
    questionnaire
  end

  factory :bookmark do
    url { "MyText" }
    title { "MyText" }
    description { "MyText" }
    user_id { 1 }
    topic_id { 1 }
  end

  factory :bookmark_rating do
    bookmark
    user
  end

  factory :choice_question, parent: :question do
  end

  factory :course do
    name { "Course_#{SecureRandom.hex(8)}" }
    directory_path { "directory_path_#{SecureRandom.hex(8)}" }
    instructor
    institution # This allows the factory to use a provided institution
  end

  factory :course_node, parent: :node do
  end

  factory :institution do
    sequence(:name) { |n| "Institution_#{n}_#{SecureRandom.hex(4)}" }
  end

  factory :instructor, class: 'Instructor' do
    sequence(:name) { |n| "instructor#{n}_#{Faker::Internet.username}" }
    sequence(:email) { |n| "instructor#{n}_#{Faker::Internet.email}" }
    password { 'password' }
    full_name { Faker::Name.name }
    institution
    role { Role.find_by(name: 'instructor') || create(:role, name: 'instructor') }
  end

  factory :invitation do
    to_user
    from_user
    assignment
  end

  factory :join_team_request do
  end

  factory :node do
    parent { nil }
    children { nil }
  end

  factory :participant do
    user
    assignment
    join_team_requests
    team { nil }
  end

  factory :question do
    questionnaire
    txt { "Sample question text" }
    weight { 1 }
    question_type { "Criterion" }
    break_before { true }
    seq { 1 }  # Ensure sequence number is set
    # Add other attributes as needed
  end

  factory :questionnaire do
    skip_create
    name { "Sample Questionnaire" }
    max_question_score { 5 }
    min_question_score { 0 }
    private { false }
    instructor
  end

  factory :quiz_questionnaire, parent: :question do
  end

  factory :response do
    response_map
    scores
  end

  factory :response_map do
    response
    reviewer
    reviewee
    assignment
  end

  factory :review_response_map, parent: :response_map do
    reviewee
  end

  factory :role do
    name
    parent { nil }
    users
  end

  factory :scored_question, parent: :choice_question do
  end

  factory :sign_up_topic do
    signed_up_teams
    teams
    assignment_questionnaires
    assignment
  end
  
  factory :signed_up_team do
    sign_up_topic
    team
  end


  factory :student_task do
    assignment { nil }
    current_stage { "MyString" }
    participant { nil }
    stage_deadline { "2024-04-15 15:55:54" }
    topic { "MyString" }
  end
  
  factory :super_administrator, parent: :user do
  end

  factory :ta, parent: :user do
  end
  
  factory :ta_mapping do
    course
    ta
  end

  factory :team do
    assignment
  end
  
  factory :teams_user do
    user
    team
  end
  
  factory :user do
    sequence(:name) { |n| "user#{n}_#{Faker::Internet.username}" }
    sequence(:email) { |n| "user#{n}_#{Faker::Internet.email}" }
    password { 'password' }
    full_name { Faker::Name.name }
    institution
    role { Role.find_by(name: 'student') || create(:role, name: 'student') }
  end
end
