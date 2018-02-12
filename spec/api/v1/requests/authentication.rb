require 'rails_helper'

describe 'Authentication API' do
  let!(:user) { create :user, id: 1 }
  let(:params) { {} }
  let(:user_data) do
    {
      'email' => user.email,
      'admin' => false,
      'token' => 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
    }
  end

  context 'success' do
    before do
      Timecop.freeze(2018, 1, 1, 0, 0, 1, 1)
      post '/api/v1/auth', params: params.merge(email: user.email, password: 'asdf1234')
    end

    after { Timecop.return }

    it 'returns user data with token' do
      expect(JSON.parse(response.body).dig('data', 'attributes')).to eq(user_data)
    end
  end

  context 'failure' do
    before do
      post '/api/v1/auth', params: params.merge(email: 'invalid@test.com', password: 'invalid')
    end

    it 'returns error' do
      expect(JSON.parse(response.body)['error']).to eq('Invalid credentials')
    end
  end
end
