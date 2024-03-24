class SignUpSheet < ApplicationRecord
  # Team lazy initialization method [zhewei, 06/27/2015]
  def self.signup_team(assignment_id, user_id, topic_id = nil)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    if users_team.empty?
      # if team is not yet created, create new team.
      # create Team and TeamNode
      team = AssignmentTeam.create_team_with_users(assignment_id, [user_id])
      # create SignedUpTeam
      confirmationStatus = SignUpSheet.confirmTopic(user_id, team.id, topic_id, assignment_id) if topic_id
    else
      confirmationStatus = SignUpSheet.confirmTopic(user_id, users_team[0].t_id, topic_id, assignment_id) if topic_id
    end
    ExpertizaLogger.info "The signup topic save status:#{confirmationStatus} for assignment #{assignment_id} by #{user_id}"
    confirmationStatus
  end

  def self.confirmTopic(user_id, team_id, topic_id, assignment_id)
    # check whether user has signed up already
    user_signup = SignUpSheet.otherConfirmedTopicforUser(assignment_id, team_id)
    users_team = SignedUpTeam.find_team_users(assignment_id, user_id)
    team = Team.find(users_team.first.t_id)
    if SignedUpTeam.where(team_id: team.id, topic_id: topic_id).any?
      return false
    end

    sign_up = SignedUpTeam.new
    sign_up.topic_id = topic_id
    sign_up.team_id = team_id
    result = false
    if user_signup.empty?

      # Using a DB transaction to ensure atomic inserts
      ApplicationRecord.transaction do
        # check whether slots exist (params[:id] = topic_id) or has the user selected another topic
        team_id, topic_id = create_SignUpTeam(assignment_id, sign_up, topic_id, user_id)
        result = true if sign_up.save
      end
    else
      # This line of code checks if the "user_signup_topic" is on the waitlist. If it is not on the waitlist, then the code returns 
      # false. If it is on the waitlist, the code continues to execute.
      user_signup.each do |user_signup_topic|
        return false unless user_signup_topic.is_waitlisted
      end

      # Using a DB transaction to ensure atomic inserts
      ApplicationRecord.transaction do
        # check whether user is clicking on a topic which is not going to place him in the waitlist
        result = sign_up_wailisted(assignment_id, sign_up, team_id, topic_id)
      end
    end

    result
  end

  class << self
    private

    def process_review_round(assignment_id, duedate, round, topic)
      duedate_rev, duedate_subm = find_topic_duedates(round, topic)

      if duedate_subm.nil? || duedate_rev.nil?
        # the topic is new. so copy deadlines from assignment
        set_of_due_dates = AssignmentDueDate.where(parent_id: assignment_id)
        set_of_due_dates.each do |due_date|
          DeadlineHelper.create_topic_deadline(due_date, 0, topic.id)
        end
        duedate_rev, duedate_subm = find_topic_duedates(round, topic)
      end

      duedate['submission_' + round.to_s] = DateTime.parse(duedate_subm['due_at'].to_s).strftime('%Y-%m-%d %H:%M:%S')
      duedate['review_' + round.to_s] = DateTime.parse(duedate_rev['due_at'].to_s).strftime('%Y-%m-%d %H:%M:%S')
    end

    def find_topic_duedates(round, topic)
      deadline_type_subm = DeadlineType.find_by(name: 'submission').id
      duedate_subm = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_subm, round: round).first
      deadline_type_rev = DeadlineType.find_by(name: 'review').id
      duedate_rev = TopicDueDate.where(parent_id: topic.id, deadline_type_id: deadline_type_rev, round: round).first
      [duedate_rev, duedate_subm]
    end
  end

  def self.import(row_hash, session, _id = nil)
    raise 'Not enough items: expect 2 or more columns: Topic Identifier, User Name 1, User Name 2, ...' if row_hash.length < 2

    imported_topic = SignUpTopic.where(topic_identifier: row_hash[:topic_identifier], assignment_id: session[:assignment_id]).first

    raise ImportError, 'Topic, ' + row_hash[:topic_identifier].to_s + ', was not found.' if imported_topic.nil?

    params = 1
    while row_hash.length > params
      index = 'user_name_' + params.to_s

      user = User.find_by(name: row_hash[index.to_sym].to_s)
      raise ImportError, 'The user, ' + row_hash[index.to_sym].to_s.strip + ', was not found.' if user.nil?

      participant = AssignmentParticipant.where(parent_id: session[:assignment_id], user_id: user.id).first
      raise ImportError, 'The user, ' + row_hash[index.to_sym].to_s.strip + ', not present in the assignment.' if participant.nil?

      signup_team(session[:assignment_id], user.id, imported_topic.id)
      params += 1
    end
  end
end