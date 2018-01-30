require 'rails_helper'

describe AuthenticateUser do
  let!(:user) { create(:user, id: 1) }

  context 'with right user and password' do
    before { Timecop.freeze(2018, 1, 1, 0, 0, 1, 1) }
    after { Timecop.return }

    let(:expected_token) do
      'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE1MTQ4NTEyMDF9._F7dC0jMOU3R3q7yl9t60ABgQ0PxHqHY2cKPxMIpfUg'
    end

    subject { described_class.call(params: { user: user.email, password: 'asdf1234' }) }

    it { expect(subject.success?).to be }
    it { expect(subject.token).to eq expected_token }
  end

  context 'with right user and wrong password' do
    subject { described_class.call(params: { user: user.email, password: 'asdf' }) }

    it { expect(subject.success?).to_not be }
    it { expect(subject.token).to_not be }
  end

  context 'with everything wrong' do
    subject { described_class.call(params: { user: 'bad_user@test.com', password: 'asdf' }) }

    it { expect(subject.success?).to_not be }
    it { expect(subject.token).to_not be }
  end
end
