FactoryBot.define do
    factory :assignment, class: Assignment do
        # Help multiple factory-created assignments get unique names
        # Let the first created assignment have the name 'final2' to avoid breaking some fragile existing tests
        name { (Assignment.last ? ('assignment' + (Assignment.last.id + 1).to_s) : 'final2').to_s }
        directory_path { "final_test" }
        submitter_count { 0 }
        course { Course.first || association(:course) }
        instructor { Instructor.first || association(:instructor) }
        private { false }
        num_reviews { 1 } 
        num_review_of_reviews { 1 }
        num_review_of_reviewers { 1} 
        reviews_visible_to_all { false }  
        num_reviewers { 1 }
        spec_location { 'https://expertiza.ncsu.edu/' }
        max_team_size { 3 }
        staggered_deadline { false }
        allow_suggestions { false }
        review_assignment_strategy { 'Auto-Selected' }
        max_reviews_per_submission { 2 }
        review_topic_threshold { 0 }
        copy_flag { false }
        rounds_of_reviews { 2 }
        vary_by_round? { false }
        vary_by_topic? { false }
        microtask { false }
        require_quiz { false }
        num_quiz_questions { 0 }
        is_coding_assignment { false }
        is_intelligent { false }
        calculate_penalty { false }
        late_policy_id { nil }
        is_penalty_calculated { false }
        show_teammate_reviews { true }
        availability_flag { true }
        use_bookmark { false }
        can_review_same_topic { true }
        can_choose_topic_to_review { true }
        num_reviews_required { 3 }
        num_metareviews_required { 3 }
        num_reviews_allowed { 3 }
        num_metareviews_allowed { 3 }
        is_calibrated { false }
        has_badge { false }
        allow_selecting_additional_reviews_after_1st_round { false }
        auto_assign_mentor { false }
      end
  end
  