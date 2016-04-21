class LeaderboardValidator
  def client
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = "LS3uMTpegVA1hg1EVsnYBSzh9"
      config.consumer_secret = "Gz3hw6rhT4Cyb6Veh8HpCw8AQmS74d4dEC3tdknRl5p50V4FJe"
      config.access_token = "709456503447625728-aJJhp7yzsUW9iR2Ia2UFugdPyeJzwqv"
      config.access_token_secret = "NfEJBb6WflVl9Woze0wyQ0UtJkwSD8BJLWls3LDnVMdTJ"
    end
  end

  def should_be_on_leaderboard?(username)
    did_tweet?(username) && did_follow?(username)
  end

  def did_tweet?(username)
    search_result = client.search("from:#{username} #dojosnake", result_type: "recent") # ['anything']
    !search_result.first.nil? # true
  end

  def did_follow?(username)
    client.friendship?(username, 'EmcDojo')
  end
end
