class TextArea < Item
    def complete(count,answer = nil)
      {
        action: 'complete',
        data: {
          count: count,
          comment: answer&.comments,
          size: size || '70,1', # Assuming '70,1' is the default size
        }
      }.to_json
    end
  
    def view_completed_item(count, answer)
      {
        action: 'view_completed_item',
        data: {
          count: count,
          comment: answer.comments
        }
      }.to_json
    end
  end