class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  acts_as_favoritor


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

end
