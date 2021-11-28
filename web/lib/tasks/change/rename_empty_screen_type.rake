namespace :change do
    desc 'Rename empty screen type in screenings'
    task rename_empty_screen_type: :environment do
        Screening.where(screen_type: 'Nenhuma exibição').update_all(screen_type: '2D')
				puts "Done!"
    end
end