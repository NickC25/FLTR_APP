class YoutubeApi
  DEVELOPER_KEY = "AIzaSyCtHmFVRrwGdZhAcofbs-xKlx56XgdB0zI"
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

  def self.get_service
    client = Google::APIClient.new(
      :key => DEVELOPER_KEY,
      :authorization => nil,
      :application_name => "Filter",
      :application_version => '1.0.0'
    )
    youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

    return client, youtube
  end

  def self.search(term)
    opts = Trollop::options do
      opt :q, 'Search term', :type => String, :default => term
      opt :max_results, 'Max results', :type => :int, :default => 25
    end

    client, youtube = get_service

    begin
      # Call the search.list method to retrieve results matching the specified
      # query term.
      search_response = client.execute!(
        :api_method => youtube.search.list,
        :parameters => {
          :part => 'snippet',
          :q => opts[:q],
          :maxResults => opts[:max_results]
        }
      )

      videos = []
      channels = []
      playlists = []

      # Add each result to the appropriate list, and then display the lists of
      # matching videos, channels, and playlists.
      search_response.data.items.each do |search_result|
        case search_result.id.kind
          when 'youtube#video'
            videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
          when 'youtube#channel'
            channels << "#{search_result.snippet.title} (#{search_result.id.channelId})"
          when 'youtube#playlist'
            playlists << "#{search_result.snippet.title} (#{search_result.id.playlistId})"
        end
      end

      # puts "Videos:\n", videos, "\n"
      # puts "Channels:\n", channels, "\n"
      # puts "Playlists:\n", playlists, "\n"
      videos
    rescue Google::APIClient::TransmissionError => e
      puts e.result.body
    end
  end

  def self.get_video_details(*video_ids)
    client, youtube = get_service
    search_response = client.execute!(
      api_method: youtube.videos.list,
      parameters: {
        part: 'statistics',
        id: video_ids.join(',')
      }
    )

    videos = []
    search_response.data.items.each do |search_result|

      if (search_result.statistics.viewCount.to_i / search_result.statistics.dislikeCount.to_i) > 100
        videos << search_result
      end
      return videos
    end
  end

end
