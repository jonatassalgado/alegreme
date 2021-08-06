namespace :clean do
    desc 'Remove repetead screenings'
    task repeated_screenings: :environment do
        Screening.where.not(id: Screening.group([:cinema_id, :movie_id, :day, :language, :screen_type]).select("max(id)")).destroy_all
    end
end