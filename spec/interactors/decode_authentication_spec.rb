require 'rails_helper'

describe DecodeAuthentication do
  context 'without token' do
    subject { described_class.call(headers: '') }

    it { expect(subject.success?).to_not be }
    it { expect(subject.type).to eq(:token) }
    it { expect(subject.message).to include('Token is missing') }
  end

  context 'with expired token' do
    let!(:user) { create(:user, id: 1) }
    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
      }
    end

    subject { described_class.call(headers: expired_header) }

    it { expect(subject.success?).to_not be }
    it { expect(subject.type).to eq(:token) }
    it { expect(subject.message).to include('Token is expired') }
  end

  context 'with invalid token' do
    before { Timecop.freeze(2018, 1, 1) }
    after { Timecop.return }

    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
      }
    end

    subject { described_class.call(headers: expired_header) }

    it { expect(subject.success?).to eq(false) }
    it { expect(subject.type).to eq(:token) }
    it { expect(subject.message).to include('Token is invalid') }
  end

  context 'with valid token' do
    before { Timecop.freeze(2018, 1, 1) }
    after { Timecop.return }
    let!(:user) { create(:user, id: 1) }

    let(:expired_header) do
      {
        'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
      }
    end

    subject { described_class.call(headers: expired_header) }

    it { expect(subject.success?).to be }
    it { expect(subject.message).to be_falsey }
  end
end
