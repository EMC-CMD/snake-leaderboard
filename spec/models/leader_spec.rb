require 'rails_helper'
require 'leaderboard_validator'
require 'set'

RSpec.describe Leader, type: :model do
  before do
    allow(LeaderboardValidator).to receive(:new).and_return(leaderboard_validator)
  end

  let(:leaderboard_validator) { double }

  context 'when there are 10 players' do
    before do
      (1..9).each do |i|
        Leader.create(twitter_handle: "user#{i}", score: i, validated: true)
      end
      leader10
    end

    let(:leader10) do
      Leader.create(twitter_handle: "user10", score: 10, validated: false)
    end

    it 'doesn\'t mark validated=true for users that are not valid' do
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('user10').and_return(false)
      Leader.validate_all
      expect(leader10.reload.validated?).to eql(false)
    end

    it 'validates records that haven\'t been validated' do
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('user10').and_return(true)
      Leader.validate_all
      expect(leader10.reload.validated?).to eql(true)
    end
  end

  context 'when there is an unvalidated leader older than 10 minutes' do
    it 'should delete the user' do
      xhe = Leader.create(twitter_handle: 'xhe', score: -32, validated: false, created_at: Time.now - 20.minutes)
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('xhe').and_return(false)
      Leader.validate_all
      expect { xhe.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
