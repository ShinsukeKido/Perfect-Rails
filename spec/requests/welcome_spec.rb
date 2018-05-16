require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'GET Welcome#index' do
    it 'returns http success' do
      get '/welcome/index'
      expect(response).to have_http_status(:success)
    end
  end
end
