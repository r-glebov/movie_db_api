require 'rails_helper'

describe 'Movies API', elasticsearch: true do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:user_context) { instance_double('Context', result: user) }

  before do
    allow(DecodeAuthentication).to receive(:call) { user_context }
  end

  context 'GET /api/v1/movies' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      sleep 2
      get '/api/v1/movies'
    end

    it 'returns movies list' do
      expected_result = {
        facets: { rating: { 1 => 1 } },
        stats: { total_entries: 1 },
        results: MovieCollectionSerializer.new([movie]).serializable_hash
      }.to_json
      expect(response.body).to eq(expected_result)
    end
  end

  context 'GET /api/v1/movies?pagination[page]=1&pagination[per_page]=5' do
    let!(:movies) { create_list :movie, 10, user_id: user.id }

    before do
      sleep 2
      get '/api/v1/movies?pagination[page]=1&pagination[per_page]=5'
    end

    it 'returns paginated movies list' do
      expected_result = {
        facets: { rating: { 1 => 10 } },
        stats: { total_entries: 10, page: 1, per_page: 5 },
        results: MovieCollectionSerializer.new(movies.first(5)).serializable_hash
      }.to_json
      expect(response.body).to eq(expected_result)
    end
  end

  context 'GET /api/v1/movies?filters[rating]=4' do
    let!(:movies_with_rating_4) { create_list :movie, 2, :rating_4, user_id: user.id }
    let!(:movies_with_rating_5) { create_list :movie, 2, :rating_5, user_id: user.id }

    before do
      sleep 2
      get '/api/v1/movies?filters[rating]=4'
    end

    it 'returns filtered movies by rating filter' do
      expected_result = {
        facets: { rating: { 4 => 2 } },
        stats: { total_entries: 2 },
        results: MovieCollectionSerializer.new(movies_with_rating_4).serializable_hash
      }.to_json
      expect(response.body).to eq(expected_result)
    end
  end

  context 'GET /api/v1/movies/:id' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      get "/api/v1/movies/#{movie.id}"
    end

    it 'returns requested movie' do
      expect(response.body).to eq(MovieSerializer.new(movie, include: [:genres]).serialized_json)
    end
  end

  context 'POST /api/v1/movies' do
    before do
      allow(DecodeAuthentication).to receive(:call) { user_context }
      post '/api/v1/movies', params: { movie: params.merge(title: 'Movie title', user_id: user.id) }
    end

    it 'creates new movie' do
      expect(Movie.count).to eq(1)
    end
  end

  context 'PUT /api/v1/movies/:id' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      allow(DecodeAuthentication).to receive(:call) { user_context }
      put "/api/v1/movies/#{movie.id}", params: { movie: params.merge(title: 'Movie title', user_id: user.id) }
    end

    it 'updates the movie' do
      movie.reload
      expect(movie.title).to eq('Movie title')
    end
  end

  context 'DELETE /api/v1/movies/:id' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      allow(DecodeAuthentication).to receive(:call) { user_context }
      delete "/api/v1/movies/#{movie.id}"
    end

    it 'deletes the movie' do
      expect(response.status).to eq(204)
    end
  end
end
