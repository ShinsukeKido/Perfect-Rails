require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'root' do
    it 'index.html.erb ページに遷移する' do
      get '/'
      expect(response).to render_template :index
    end
  end
end
