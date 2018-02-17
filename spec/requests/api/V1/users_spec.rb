require 'rails_helper'

describe 'Users API' do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:user_context) { instance_double('Context', result: user) }

  before do
    allow(DecodeAuthentication).to receive(:call) { user_context }
  end

  context 'GET /api/v1/users' do
    let!(:user) { create :user }

    before do
      get '/api/v1/users'
    end

    it 'returns users list' do
      expect(response.body).to eq(UserSerializer.new([user]).serialized_json)
    end
  end

  context 'GET /api/v1/users/:id' do
    let!(:user) { create :user }

    before do
      get "/api/v1/users/#{user.id}"
    end

    it 'returns requested user' do
      expect(response.body).to eq(UserSerializer.new(user).serialized_json)
    end
  end

  context 'POST /api/v1/users' do
    it 'creates new user' do
      user_params = { user: params.merge(email: 'user@test.com',
                                         password: 'asdf1234',
                                         password_confirmation: 'asdf1234') }
      expect { post '/api/v1/users', params: user_params }.to change { User.count }.by(1)
    end
  end

  context 'PUT /api/v1/users/:id' do
    let!(:user) { create :user }

    before do
      user_params = { user: params.merge(email: user.email,
                                         password: 'new_password',
                                         password_confirmation: 'new_password') }
      put "/api/v1/users/#{user.id}", params: user_params
    end

    it 'updates the user' do
      user.reload
      expect(user.authenticate('new_password')).to eq(user)
    end
  end

  context 'DELETE /api/v1/users/:id' do
    let!(:user) { create :user }

    before do
      delete "/api/v1/users/#{user.id}"
    end

    it 'deletes the user' do
      expect(response.status).to eq(204)
    end
  end
end
