require 'rails_helper'

describe 'Ratings API', elasticsearch: true do
  let!(:user_1) { create :user, id: 1 }
  let!(:user_2) { create :user, id: 2 }
  let(:params) { {} }
  let(:user_1_context) { instance_double('Context', result: user_1) }
  let(:user_2_context) { instance_double('Context', result: user_2) }

  context 'PUT /api/v1/ratings/:movie_id' do
    let!(:movie) { create :movie, user_id: user_1.id }

    it 'updates the movie with a correct average rating' do
      allow(DecodeAuthentication).to receive(:call) { user_1_context }
      put "/api/v1/ratings/#{movie.id}", params: { rating: { score: 5 } }
      allow(DecodeAuthentication).to receive(:call) { user_2_context }
      put "/api/v1/ratings/#{movie.id}", params: { rating: { score: 1 } }
      movie.reload
      expect(movie.rating).to eq(3.0)
    end
  end
end
