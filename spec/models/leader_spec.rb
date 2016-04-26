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

  it 'should not update your score if its lower than a previous score' do
    Timecop.travel(Time.local(2016, 5, 2, 18, 0, 0)) do
      l1 = Leader.put(twitter_handle: 'l1', score: 23, validated: true)
      l2 = Leader.put(twitter_handle: 'l1', score: 10)

      expect(l1.reload.score).to eql(23)
    end
  end

  it 'should create a new record instead of updating the existing one when in a different range' do
    Timecop.travel(Time.local(2016, 5, 2, 18, 0, 0)) do
      l1 = Leader.put(twitter_handle: 'l1', score: 23, validated: true)
      l2 = Leader.put(twitter_handle: 'l1', score: 35)
      expect(Leader.current_leaders.to_a).to eql([l2])
    end

    Timecop.travel(Time.local(2016, 5, 2, 21, 0, 0)) do
      l3 = Leader.put(twitter_handle: 'l1', score: 25, validated: true)
      expect(Leader.current_leaders.to_a).to eql([l3])
    end
  end

  it 'should only show leaders from the current time window' do
    Timecop.travel(Time.local(2016, 5, 1, 17, 0, 0)) do
      l1 = Leader.create(twitter_handle: 'l1', score: 23, validated: true)
      expect(Leader.current_leaders).to be_empty
    end

    Timecop.travel(Time.local(2016, 5, 2, 18, 0, 0)) do
      l2 = Leader.create(twitter_handle: 'l2', score: 23, validated: true)
      expect(Leader.current_leaders.to_a).to eql([l2])
    end

    Timecop.travel(Time.local(2016, 5, 2, 21, 0, 0)) do
      l3 = Leader.create(twitter_handle: 'l3', score: 23, validated: true)
      expect(Leader.current_leaders.to_a).to eql([l3])
    end

    Timecop.travel(Time.local(2016, 5, 3, 17, 0, 0)) do
      l4 = Leader.create(twitter_handle: 'l4', score: 23, validated: true)
      expect(Leader.current_leaders.to_a).to eql([l4])
    end

    Timecop.travel(Time.local(2016, 5, 4, 17, 0, 0)) do
      l5 = Leader.create(twitter_handle: 'l5', score: 23, validated: true)
      expect(Leader.current_leaders).to be_empty
    end
  end
end
