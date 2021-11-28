namespace :clean do
    desc 'Remove old screenings'
    task old_screenings: :environment do
         ScreeningGroup.where("date <= ?", DateTime.now - 1).destroy_all
    end
end