class FilterController < ApplicationController
  def index
    videos_info =  YoutubeApi.search("#{params[:search] || ''}")
    video_ids = []
    videos_info.each do |video|
      id = video.split("(").last.split(")")[0]
      video_ids << id
    end
    if video_ids.length > 0
      @has_result = true
    end
    @videos = YoutubeApi.get_video_details(video_ids)
  end
end
