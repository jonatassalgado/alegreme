class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  devise :omniauthable, omniauth_providers: [:google_oauth2]


  def personas_primary_name
    self.features['psychographic']['personas']['primary']['name'] if self.features['psychographic']
  end

  def personas_primary_name= value
    self.features['psychographic']['personas']['primary']['name'] = value
  end

  def personas_secondary_name
    self.features['psychographic']['personas']['secondary']['name'] if self.features['psychographic']
  end

  def personas_secondary_name= value
    self.features['psychographic']['personas']['secondary']['name'] = value
  end

  def personas_primary_score
    self.features['psychographic']['personas']['primary']['score'] if self.features['psychographic']
  end

  def personas_primary_score= value
    self.features['psychographic']['personas']['primary']['score'] = value
  end

  def personas_secondary_score
    self.features['psychographic']['personas']['secondary']['score'] if self.features['psychographic']
  end

  def personas_secondary_score= value
    self.features['psychographic']['personas']['secondary']['score'] = value
  end

  def personas_tertiary_name
    self.features['psychographic']['personas']['tertiary']['name'] if self.features['psychographic']
  end

  def personas_tertiary_name= value
    self.features['psychographic']['personas']['tertiary']['name'] = value
  end

  def personas_quartenary_name
    self.features['psychographic']['personas']['quartenary']['name'] if self.features['psychographic']
  end

  def personas_quartenary_name= value
    self.features['psychographic']['personas']['quartenary']['name'] = value
  end

  def personas_tertiary_score
    self.features['psychographic']['personas']['tertiary']['score'] if self.features['psychographic']
  end

  def personas_tertiary_score= value
    self.features['psychographic']['personas']['tertiary']['score'] = value
  end

  def personas_quartenary_score
    self.features['psychographic']['personas']['quartenary']['score'] if self.features['psychographic']
  end

  def personas_quartenary_score= value
    self.features['psychographic']['personas']['quartenary']['score'] = value
  end



  def personas_assortment_finished?
    self.features['psychographic']['personas']['assortment']['finished'] if self.features['psychographic']
  end

  def personas_assortment_finished= value
    self.features['psychographic']['personas']['assortment']['finished'] = value
  end


  def taste_events_save event_id    
    event = Event.find event_id

    ActiveRecord::Base.transaction do
      event.entries['saved_by'] << self.id
      event.entries['total_saves'] += 1

      validate_taste_existence 'events'
      self.taste['events']['saved'] << event_id
      self.taste['events']['total_saves'] += 1
      
      return event.save && self.save
    end
  rescue ActiveRecord::RecordInvalid
    puts "Não foi possível salvar sua ação (ERRO 7813)!"
  end


  def taste_events_unsave event_id  
    event = Event.find event_id

    ActiveRecord::Base.transaction do
      event.entries['saved_by'].delete self.id 
      event.entries['total_saves'] -= 1
      
      validate_taste_existence 'events'
      self.taste['events']['saved'].delete event_id
      self.taste['events']['total_saves'] -= 1
      
      return event.save && self.save
    end
  rescue ActiveRecord::RecordInvalid
    puts "Não foi possível salvar sua ação (ERRO 7814)!"
  end

  def taste_events_saved? event_id
    if self.taste['events']
      self.taste['events']['saved'].include? event_id
    else
      return false
    end
  end


  def taste_events_saved
    self.taste['events']['saved']
  end



  def self.from_omniauth(access_token, guest_user, params)
 
    data     = access_token.info
    user     = User.where(email: data['email']).first
    state    = Base64.urlsafe_decode64(params['state'])
    personas = {}
    
    raise Exception.new('JSON de personas com enconding incorreto!') unless ['UTF-8', 'US-ASCII', 'ASCII-8BIT'].include? state.encoding.name
    
    def begin
      personas = YAML.load(state)
    rescue StandardError
      puts "O state retornado não é um YAML válido "
    else
      if personas && personas['assortment']['finished']
        features = {  
          psychographic: {
            personas: {
              primary: {
                name: personas['primary']['name'],
                score: personas['primary']['score']
              },
              secondary: {
                name: personas['secondary']['name'],
                score: personas['secondary']['score']
              },
              tertiary: {
                name: personas['tertiary']['name'],
                score: personas['tertiary']['score']
              },
              quartenary: {
                name: personas['quartenary']['name'],
                score: personas['quartenary']['score']
              },
              assortment: { 
                finished: personas['assortment']['finished'], 
                finished_at: personas['assortment']['finished_at'] 
              } 
            }
          }
        }
      end
    end

    

    if user && !personas.empty? && personas['assortment']['finished']
      user.update_attributes(features: features)
      return user
    elsif !personas.empty? && personas['assortment']['finished']
      return User.create(email: data['email'], password: Devise.friendly_token[0, 20], features: features)
    elsif user
      return user
    else
      return User.create(email: data['email'], password: Devise.friendly_token[0, 20], features: guest_user.features)
    end

  end



  private 

  def validate_taste_existence(dictionary = 'events')
    self.taste[dictionary] ||= {}

    if dictionary == 'events'
      self.taste[dictionary]['saved']          ||= [] 
      self.taste[dictionary]['liked']          ||= [] 
      self.taste[dictionary]['viewed']         ||= [] 
      self.taste[dictionary]['disliked']       ||= [] 
      self.taste[dictionary]['total_saves']    ||= 0 
      self.taste[dictionary]['total_likes']    ||= 0
      self.taste[dictionary]['total_views']    ||= 0
      self.taste[dictionary]['total_dislikes'] ||= 0
    end
  end

end
