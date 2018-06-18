require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '#comment' do
    it { should allow_value(nil).for(:comment) }
    it { should validate_length_of(:comment).is_at_most(30) }
  end
end
