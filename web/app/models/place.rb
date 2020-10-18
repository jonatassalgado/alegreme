class Place < ApplicationRecord

  validate :uniq_details_name, on: :create

  extend FriendlyId
  friendly_id :details_name, use: :slugged

  include PlaceImageUploader::Attachment.new(:image)

  has_many :events
  has_many :follows, as: :following

  def details_name
    self.details['name']
  end

  def details_name=(value)
    self.details['name'] = value
  end

  def geographic_address
    self.geographic['address']
  end

  private

  def uniq_details_name
    if Place.where("lower(details ->> 'name') = ?", details['name'].downcase).present?
      errors.add(:details_name, "O nome do local precisa ser único")
    end
  end

end
