require 'rails_helper'

RSpec.describe LeadersController, type: :controller do
  it 'can post to create a leader' do
    Leader.delete_all
    twitter_handle = SecureRandom.uuid
    post :create,
         token: '4505d16a-230b-4832-b521-93499f696bb3',
         leader: {
           twitter_handle: twitter_handle,
           score: 10
         }
    expect(Leader.where(twitter_handle: twitter_handle, score: 10)).to be_present
  end

  it 'updates existing leaders\' scores instead of creating new ones when the leader already exists' do
    allow(Leader).to receive(:put)
    post :create,
         token: '4505d16a-230b-4832-b521-93499f696bb3',
         leader: {
           twitter_handle: 'xhe',
           score: 10
         }

    expect(Leader).to have_received(:put).with(twitter_handle: 'xhe', score: "10")
  end

  it 'validates when you get the validate endpoint' do
    allow(Leader).to receive(:validate_all)
    get :validate, token: '2e326efa-268a-4117-9e40-517679356a35'
    expect(Leader).to have_received(:validate_all)
  end

  it 'does not validate when you get the validate endpoint with an invalid token' do
    allow(Leader).to receive(:validate_all)
    get :validate, token: 'invalid'
    expect(Leader).to_not have_received(:validate_all)
  end

  it 'gets top 10 existing leaders' do
    Leader.delete_all
    Timecop.travel(Time.local(2016, 5, 2, 18, 0, 0)) do
      leaders = (1..11).map do |i|
        Leader.create(twitter_handle: 'someone'+i.to_s, score: i, validated: true)
      end
      get :index, format: :json
      result = JSON.parse(response.body)
      expect(result.size).to eql(10)
      expect(result).to eql(
        leaders.sort_by(&:score).reverse.take(10).map do |l|
          {'twitter_handle' => l.twitter_handle, 'score' => l.score}
        end
      )
    end
  end
end
