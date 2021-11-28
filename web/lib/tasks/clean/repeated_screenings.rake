namespace :clean do
    desc 'Remove repeated screenings'
    task repeated_screenings: :environment do
        Screening.where.not(id: Screening.group([:screening_group_id, :language, :screen_type]).select("max(id)")).destroy_all
        puts "Done!"
    end
end