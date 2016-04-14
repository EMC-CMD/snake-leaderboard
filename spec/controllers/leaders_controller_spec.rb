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

  it 'gets top 10 existing leaders' do
    Leader.delete_all
    leaders = (1..11).map do |i|
      Leader.create(twitter_handle: 'someone'+i.to_s, score: i)
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
