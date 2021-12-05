require 'net/http'
require 'openssl'
require 'uri'
require 'json'

namespace :clean do
    desc 'Remove likes and swipable from all users'
    task likes: :environment do

        users = User.all
        users.each do |u|
            Rails.cache.delete_matched("#{u.cache_key}/hero--swipable/suggestions_viewed")
            u.likes.destroy_all
            u.swipable.deep_merge!({
                                    :events => {
                                        :last_view_at => nil,
                                        :finished_at  => nil,
                                        :hidden_at    => nil,
                                        :active       => true
                                    }
                                })

            u.save
				end
				Rails.cache.clear
    end
end