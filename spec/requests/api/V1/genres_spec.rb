require 'rails_helper'

describe 'Genres API' do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:user_context) { instance_double('Context', result: user) }

  before do
    allow(DecodeAuthentication).to receive(:call) { user_context }
  end

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
      post '/api/v1/genres', params: { genre: params.merge(name: 'Genre name') }
    end

    it 'creates new genre' do
      expect(Genre.count).to eq(1)
    end
  end

  context 'PUT /api/v1/genres/:id' do
    let!(:genre) { create :genre }

    before do
      put "/api/v1/genres/#{genre.id}", params: { genre: params.merge(name: 'Genre name') }
    end

    it 'updates the genre' do
      genre.reload
      expect(genre.name).to eq('Genre name')
    end
  end

  context 'DELETE /api/v1/genres/:id' do
    let!(:genre) { create :genre }

    before do
      delete "/api/v1/genres/#{genre.id}"
    end

    it 'deletes the genre' do
      expect(response.status).to eq(204)
    end
  end
end
