module KvstoreBuilders
  def gen_video_id
    (Time.now.to_f * 1000).to_i.to_s
  end
end

RSpec.configure do |config|
  config.include KvstoreBuilders
end
