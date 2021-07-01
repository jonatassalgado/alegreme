json.id @user.id
json.name @user.features.dig('demographic', 'name')
json.email @user.email
json.slug @user.slug
json.picture @user.features.dig('demographic', 'picture')
