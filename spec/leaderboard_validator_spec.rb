require 'spec_helper'
require 'twitter'
require 'leaderboard_validator'
require 'pry'

RSpec.describe LeaderboardValidator do
  before do
    allow(Twitter::REST::Client).to receive(:new).and_yield(OpenStruct.new).and_return(client)
  end

  let(:client) { double }
  subject(:leaderboard_validator) { LeaderboardValidator.new }

  it 'validates that a user should be shown on the leaderboard' do
    allow(client).to receive(:friendship?).with('mock', 'EmcDojo').and_return(true)
    allow(client).to receive(:search).with('from:mock #dojosnake', result_type: 'recent').and_return(['anything'])

    expect(leaderboard_validator.should_be_on_leaderboard?('mock')).to eql(true)
  end

  it 'validates another user should be shown on the leaderboard' do
    allow(client).to receive(:friendship?).with('mock2', 'EmcDojo').and_return(true)
    allow(client).to receive(:search).with('from:mock2 #dojosnake', result_type: 'recent').and_return(['anything2'])

    expect(leaderboard_validator.should_be_on_leaderboard?('mock2')).to eql(true)
  end

  it 'returns false when the user is not following EmcDojo' do
    allow(client).to receive(:friendship?).with('mock2', 'EmcDojo').and_return(false)
    allow(client).to receive(:search).with('from:mock2 #dojosnake', result_type: 'recent').and_return(['anything2'])

    expect(leaderboard_validator.should_be_on_leaderboard?('mock2')).to eql(false)
  end

  it 'returns false when the user did not tweet #dojosnake' do
    allow(client).to receive(:friendship?).with('mock2', 'EmcDojo').and_return(true)
    allow(client).to receive(:search).with('from:mock2 #dojosnake', result_type: 'recent').and_return([])

    expect(leaderboard_validator.should_be_on_leaderboard?('mock2')).to eql(false)
  end
end
