require 'rails_helper'

describe 'Genres API' do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:token_header) do
    {
      'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
    }
  end

  before do
    Timecop.freeze(2018, 1, 1, 0, 0, 1, 1)
    post '/api/v1/auth', params: { email: user.email, password: 'asdf1234' }
  end

  after { Timecop.return }

  context 'GET /api/v1/genres' do
    let!(:genre) { create :genre }

    before do
      get '/api/v1/genres'
    end

    it 'returns genres list' do
      expect(response.body).to eq(GenreSerializer.new([genre]).serialized_json)
    end
  end

  context 'GET /api/v1/genres/:id' do
    let!(:genre) { create :genre }

    before do
      get "/api/v1/genres/#{genre.id}"
    end

    it 'returns requested genre' do
      expect(response.body).to eq(GenreSerializer.new(genre).serialized_json)
    end
  end

  context 'POST /api/v1/genres' do
    before do
      post '/api/v1/genres',
           params: { genre: params.merge(name: 'Genre name') },
           headers: token_header
    end

    it 'creates new genre' do
      expect(Genre.count).to eq(1)
    end
  end

  context 'PUT /api/v1/genres/:id' do
    let!(:genre) { create :genre }

    before do
      put "/api/v1/genres/#{genre.id}",
          params: { genre: params.merge(name: 'Genre name') },
          headers: token_header
    end

    it 'updates the genre' do
      genre.reload
      expect(genre.name).to eq('Genre name')
    end
  end

  context 'DELETE /api/v1/genres/:id' do
    let!(:genre) { create :genre }

    before do
      delete "/api/v1/genres/#{genre.id}", headers: token_header
    end

    it 'deletes the genre' do
      expect(response.status).to eq(204)
    end
  end
end
