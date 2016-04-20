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

    it 'gets top ten, skipping users that haven\'t been validated' do
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('user10').and_return(false)
      leaders = Leader.validate_and_get_top_ten
      expect(leaders).to_not include(leader10)
      expect(leaders.size).to eql(9)
    end

    it 'validates records that haven\'t been validated' do
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('user10').and_return(true)
      expect(Leader.validate_and_get_top_ten).to include(leader10)
      expect(leader10.reload.validated?).to eql(true)
    end
  end

  context 'when there are no users' do
    it 'should return an empty list' do
      expect(Leader.validate_and_get_top_ten).to be_empty
    end
  end

  context 'when there are no valid users' do
    before do
      Leader.create(twitter_handle: 'xhe', score: 100000, validated: false)
      allow(leaderboard_validator).to receive(:should_be_on_leaderboard?).with('xhe').and_return(false)
    end

    it 'should return an empty list' do
      expect(Leader.validate_and_get_top_ten).to be_empty
    end
  end
end
