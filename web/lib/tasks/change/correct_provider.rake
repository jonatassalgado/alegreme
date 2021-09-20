namespace :change do
	desc 'Set correct provider to users'
	task correct_provider: :environment do
		users   = User.all.order('created_at DESC')
		counter = 0

		users.each do |user|
			next if user.features['demographic']['social'].blank? || user.features['demographic']['social']['googleId'].nil? && user.features['demographic']['social']['fbId'].nil?

			if user.features['demographic']['social']['googleId'].present?
				user.provider = 'google'
			elsif user.features['demographic']['social']['fbId'].present?
				user.provider = 'facebook'
			end

			if user.save
				counter += 1
				puts "#{counter}: (#{user.id}) Usuário atualizado -> #{user.provider}"
			end
		end
	end
end