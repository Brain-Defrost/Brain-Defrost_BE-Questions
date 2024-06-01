class QuestionService 
  def self.create_trivia_questions(topic, question_number)
    query = "Write #{question_number} trivia questions about #{topic}. Answer options to the trivia questions should be three words max. Format the JSON response according to JSON:API v1.1 standards. Keys in the 'attributes' section of the response for each question should include: 'question_text', 'correct_answer', and 'answer_options' (an array of consisting of 4 answer options, including one that's the correct answer. Questions and answers should be written in english."
    
    begin
      response = post_url('/v1/chat/completions', query)

      return "Unable to create trivia questions at this time" unless response.status == 200

      JSON.parse(response.body["choices"][0]["message"]["content"], symbolize_names: true)
      
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error "Connection failed: #{e.message}"
      return "Unable to connect to the trivia service at this time"
    rescue JSON::ParserError && NoMethodError
      return "Unable to parse trivia questions at this time"
    end
  end

  def self.post_url(url, query)
    options = {
      'Content-Type' => 'application/json',
      'Authorization' => Rails.application.credentials.open_ai_key
    }

    body = {
      model: 'gpt-3.5-turbo',
      messages: [{ role: 'user', content: query,
      format: "json" }]
    }

    connection.post(url, body.to_json, options)
  end

  def self.connection
    Faraday.new(url:'https://api.openai.com') do |faraday|
      faraday.request :json
      faraday.response :json, content_type: /\bjson$/
      faraday.adapter Faraday.default_adapter
    end
  end
end