require 'rails_helper'

describe 'Movies API', elasticsearch: true do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:token_header) do
    {
      'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
    }
  end

  context 'GET /api/v1/movies' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      sleep 2
      get '/api/v1/movies'
    end

    it 'returns movies list' do
      output = {
        facets: { rating: { 1 => 1 } },
        stats: { total_entries: 1 },
        results: MovieCollectionSerializer.new([movie]).serializable_hash
      }.to_json
      expect(response.body).to eq(output)
    end
  end

  context 'GET /api/v1/movies?pagination[page]=1&pagination[per_page]=5' do
    let!(:movies) { create_list :movie, 10, user_id: user.id }

    before do
      sleep 2
      get '/api/v1/movies?pagination[page]=1&pagination[per_page]=5'
    end

    it 'returns paginated movies list' do
      output = {
        facets: { rating: { 1 => 10 } },
        stats: { total_entries: 10, page: 1, per_page: 5 },
        results: MovieCollectionSerializer.new(movies.first(5)).serializable_hash
      }.to_json
      expect(response.body).to eq(output)
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
      output = {
        facets: { rating: { 4 => 2 } },
        stats: { total_entries: 2 },
        results: MovieCollectionSerializer.new(movies_with_rating_4).serializable_hash
      }.to_json
      expect(response.body).to eq(output)
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
      Timecop.freeze(2018, 1, 1, 0, 0, 1, 1)
      post '/api/v1/auth', params: { email: user.email, password: 'asdf1234' }
      post '/api/v1/movies',
           params: { movie: params.merge(title: 'Movie title', user_id: user.id) },
           headers: token_header
    end

    after { Timecop.return }

    it 'creates new movie' do
      expect(Movie.count).to eq(1)
    end
  end

  context 'PUT /api/v1/movies/:id' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      Timecop.freeze(2018, 1, 1, 0, 0, 1, 1)
      post '/api/v1/auth', params: { email: user.email, password: 'asdf1234' }
      put "/api/v1/movies/#{movie.id}",
          params: { movie: params.merge(title: 'Movie title', user_id: user.id) },
          headers: token_header
    end

    after { Timecop.return }

    it 'updates the movie' do
      movie.reload
      expect(movie.title).to eq('Movie title')
    end
  end

  context 'DELETE /api/v1/movies/:id' do
    let!(:movie) { create :movie, user_id: user.id }

    before do
      Timecop.freeze(2018, 1, 1, 0, 0, 1, 1)
      post '/api/v1/auth',
           params: { email: user.email, password: 'asdf1234' }
      delete "/api/v1/movies/#{movie.id}", headers: token_header
    end

    after { Timecop.return }

    it 'deletes the movie' do
      expect(response.status).to eq(204)
    end
  end
end
