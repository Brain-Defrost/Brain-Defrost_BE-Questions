require 'rails_helper'

RSpec.describe QuestionService do
  describe '.create_trivia_questions(topic, question_number)' do
    let!(:question_number) { 3 }
    let!(:topic) { "music" }

    context 'happy path' do
      it 'returns generated trivia questions', :vcr do
        service_response = QuestionService.create_trivia_questions(topic, question_number)

        expect(service_response).to be_a(Hash)
        check_hash_structure(service_response, :data, Array)

        service_response[:data].each do |data|
          check_hash_structure(data, :id, String)
          check_hash_structure(data, :attributes, Hash)
          check_hash_structure(data[:attributes], :question_text, String)
          check_hash_structure(data[:attributes], :correct_answer, String)
          check_hash_structure(data[:attributes], :answer_options, Array)
          expect(data[:attributes][:answer_options].size).to eq(4)
          expect(data[:attributes][:answer_options]).to all(be_a(String))
        end
      end
    end

    context 'sad path' do
      it 'returns error message if request is unsuccessful' do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(status: 500, body: '', headers: {})

        service_response = QuestionService.create_trivia_questions(topic, question_number)
        expect(service_response).to eq('Unable to create trivia questions at this time')
      end

      it 'returns error message if response body cannot be parsed' do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(status: 200, body: 'invalid json', headers: {})

        service_response = QuestionService.create_trivia_questions(topic, question_number)
        expect(service_response).to eq("Unable to parse trivia questions at this time")
      end

      it 'returns error message if there is a connection error' do
        allow(QuestionService).to receive(:post_url).and_raise(Faraday::ConnectionFailed.new('Connection failed'))

        service_response = QuestionService.create_trivia_questions(topic, question_number)
        expect(service_response).to eq("Unable to connect to the trivia service at this time")
      end
    end
  end

  def check_hash_structure(object, key, klass)
    expect(object).to have_key(key)
    expect(object[key]).to be_a(klass)
  end
end
