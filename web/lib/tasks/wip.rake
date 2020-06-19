require 'net/http'
require 'openssl'
require 'uri'
require 'json'

task wip: :environment do
  User.all.each do |u|
    u.taste.deep_merge!({
      'movies' => {
        'saved' =>          [],
        'liked' =>          [],
        'viewed' =>         [],
        'disliked' =>       [],
        'total_saves' =>    0,
        'total_likes' =>    0,
        'total_views' =>    0,
        'total_dislikes' => 0
      }
    })
    u.save
  end
end
