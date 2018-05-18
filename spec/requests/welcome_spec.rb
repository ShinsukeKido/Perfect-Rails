require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'root' do
    it 'returns http success' do
      get '/'
      expect(response).to have_http_status(:success)
    end
  end
end
