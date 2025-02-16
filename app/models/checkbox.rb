class Checkbox < UnscoredItem
    def edit(count)
      {
        remove_button: edit_remove_button(count),
        seq: edit_seq(count),
        item: edit_question(count),
        type: edit_type(count),
        weight: edit_weight(count)
      }
    end
  
    def edit_remove_button(count)
      {
        type: 'remove_button',
        action: 'delete',
        href: "/questions/#{id}",
        text: 'Remove'
      }
    end
  
    def edit_seq(count)
      {
        type: 'seq',
        input_size: 6,
        value: seq,
        name: "item[#{id}][seq]",
        id: "question_#{id}_seq"
      }
    end
  
    def edit_question(count)
      {
        type: 'textarea',
        cols: 50,
        rows: 1,
        name: "item[#{id}][txt]",
        id: "question_#{id}_txt",
        placeholder: 'Edit item content here',
        content: txt
      }
    end
  
    def edit_type(count)
      {
        type: 'text',
        input_size: 10,
        disabled: true,
        value: question_type,
        name: "item[#{id}][type]",
        id: "question_#{id}_type"
      }
    end
  
    def edit_weight(count)
      {
        type: 'weight',
        placeholder: 'UnscoredItem does not need weight'
      }
    end
  
  
    def view_item_text
      {
        content: txt,
        type: question_type,
        weight: weight.to_s,
        checked_state: 'Checked/Unchecked'
      }
    end
  
    def complete(count, answer = nil)
      {
        previous_question: check_previous_question,
        inputs: [
          complete_first_second_input(count, answer),
          complete_third_input(count, answer)
        ],
        label: {
          for: "responses_#{count}",
          text: txt
        },
        script: complete_script(count),
        if_column_header: complete_if_column_header
      }
    end
  
    def check_previous_question
      prev_question = Item.where('seq < ?', seq).order(:seq).last
      {
        type: prev_question&.type == 'ColumnHeader' ? 'ColumnHeader' : 'other'
      }
    end
  
    def complete_first_second_input(count, answer = nil)
      [
        {
          id: "responses_#{count}_comments",
          name: "responses[#{count}][comment]",
          type: 'hidden',
          value: ''
        },
        {
          id: "responses_#{count}_score",
          name: "responses[#{count}][score]",
          type: 'hidden',
          value: answer&.answer == 1 ? '1' : '0'
        }
      ]
    end
  
    def complete_third_input(count, answer = nil)
      {
        id: "responses_#{count}_checkbox",
        type: 'checkbox',
        onchange: "checkbox#{count}Changed()",
        checked: answer&.answer == 1
      }
    end
  
    def complete_script(count)
      "function checkbox#{count}Changed() { var checkbox = jQuery('#responses_#{count}_checkbox'); var response_score = jQuery('#responses_#{count}_score'); if (checkbox.is(':checked')) { response_score.val('1'); } else { response_score.val('0'); }}"
    end
  
    def complete_if_column_header
      next_question = Item.where('seq > ?', seq).order(:seq).first
      if next_question
        case next_question.question_type
        when 'ColumnHeader'
          'end_of_column_header'
        when 'SectionHeader', 'TableHeader'
          'end_of_section_or_table'
        else
          'continue'
        end
      else
        'end'
      end
    end
  
    def view_completed_item(count, answer)
      {
        previous_question: check_previous_question,
        answer: view_completed_item_answer(count, answer),
        if_column_header: view_completed_item_if_column_header
      }
    end
  
    def view_completed_item_answer(count, answer)
      {
        number: count,
        image: answer.answer == 1 ? 'Check-icon.png' : 'delete_icon.png',
        content: txt,
        bold: true
      }
    end
  
    def view_completed_item_if_column_header
      next_question = Item.where('seq > ?', seq).order(:seq).first
      if next_question
        case next_question.question_type
        when 'ColumnHeader'
          'end_of_column_header'
        when 'TableHeader'
          'end_of_table_header'
        else
          'continue'
        end
      else
        'end'
      end
    end
  end