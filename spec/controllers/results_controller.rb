require 'rails_helper'

RSpec.describe ResultsController, type: :request do
  describe 'device_id actions' do   
    context 'create' do        
      let(:request_params) do
        {
            subject: "Science",
            timestamp: "2023-04-21",
            marks: 122.54
        }         
      end  

      it 'creates device_token' do
        post "/results", params: request_params
        data = JSON.parse(response.body)
        expect(data["message"]).to eql("saved successfully")
        expect(response).to have_http_status(200)
      end
    end
  end

end
