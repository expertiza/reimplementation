class Dropdown < UnscoredItem
    include QuestionHelper
  
    attr_accessor :txt, :type, :count, :weight
    def edit(count)
      edit_common("Item #{count}:", txt , weight, type).to_json
    end
  
    def view_item_text
      view_item_text_common(txt, type, weight, 'N/A').to_json
    end
  
    def complete(count, answer = nil)
      options = (1..count).map { |option| { value: option, selected: (option == answer.to_i) } }
      { dropdown_options: options }.to_json
    end
  
    def complete_for_alternatives(alternatives, answer)
      options = alternatives.map { |alt| { value: alt, selected: (alt == answer) } }
      { dropdown_options: options }.to_json
    end
  
    def view_completed_item
      { selected_option: (count && answer) ? "#{answer} (out of #{count})" : 'Item not answered.' }.to_json
    end
  end