class Event < ApplicationRecord
  require "day_of_week"

  include ImageUploader::Attachment.new(:image)
  include Rails.application.routes.url_helpers

  after_save :reindex, if: proc { |event| event.description_changed? }
  after_destroy :reindex, :destroy_entries

  belongs_to :place
  has_and_belongs_to_many :organizers
  # has_one_attached :cover

  accepts_nested_attributes_for :place, :organizers

  delegate :name, :address, to: :place, prefix: true, allow_nil: true

  jsonb_accessor :ocurrences, dates: [:datetime, array: true, default: []]

  searchkick callbacks: false, language: "portuguese", highlight: [:name, :description]

  scope "for_user", ->(user) {
          where("(personas -> 'primary' ->> 'name') IN (?, ?, ?, ?)", user.personas_primary_name, user.personas_secondary_name, user.personas_tertiary_name, user.personas_quartenary_name)
        }

  scope "saved_by_user", ->(user) {
          where(id: user.taste_events_saved)
        }

  scope "with_personas", ->(personas) {
          if !personas || personas.empty?
            Event.active
          else
            where("(personas -> 'primary' ->> 'name') IN (?)", personas)
          end
        }

  scope "with_categories", ->(categories) {
          if !categories || categories.empty?
            Event.active
          else
            where("(categories -> 'primary' ->> 'name') IN (?)", categories)
          end
        }

  scope "feed_for_user", ->(user, filters = { categories: ["festa", "curso", "teatro", "show", "cinema", "exposição", "feira", "aventura", "meetup", "hackaton", "palestra", "celebração", "workshop", "oficina", "aula de dança", "literatura", "festival", "acadêmico", "gastronômico", "brecho", "profissional"] }) {
      events_for_primary_persona = Event.by_category(filters[:categories], "primary", { 'not_in': ["curso"] }).by_persona(user.personas_primary_name).active.order_by_score.limit(15)
      events_for_secondary_persona = Event.by_category(filters[:categories], "secondary", { 'not_in': ["curso"] }).by_persona(user.personas_secondary_name).active.order_by_score.limit(15)
      events_for_tertiary_persona = Event.by_category(filters[:categories], "tertiary", { 'not_in': ["curso"] }).by_persona(user.personas_tertiary_name).active.order_by_score.limit(15)
      events_for_quartenary_persona = Event.by_category(filters[:categories], "quartenary", { 'not_in': ["curso"] }).by_persona(user.personas_quartenary_name).active.order_by_score.limit(15)
      
      count_primary_persona = events_for_primary_persona.count >= 0 ? events_for_primary_persona.count : 0
      count_secondary_persona = events_for_secondary_persona.count + ((5 - count_primary_persona) >= 0 ? (5 - count_primary_persona) : 0)
      count_tertiary_persona = events_for_tertiary_persona.count + (((4 + count_secondary_persona) - count_primary_persona) >= 0 ? (4 + count_secondary_persona) - count_primary_persona : 0)
      count_quartenary_persona = events_for_quartenary_persona.count + (((2 + count_tertiary_persona) - count_secondary_persona) >= 0 ? (2 + count_tertiary_persona) - count_secondary_persona : 0)

      events_for_primary_persona = Event.by_category(filters[:categories], "primary", { 'not_in': ["curso"] }).by_persona(user.personas_primary_name).active.order_by_score.limit(count_primary_persona)
      events_for_secondary_persona = Event.by_category(filters[:categories], "secondary", { 'not_in': ["curso"] }).by_persona(user.personas_secondary_name).active.order_by_score.limit(count_secondary_persona)
      events_for_tertiary_persona = Event.by_category(filters[:categories], "tertiary", { 'not_in': ["curso"] }).by_persona(user.personas_tertiary_name).active.order_by_score.limit(count_tertiary_persona)
      events_for_quartenary_persona = Event.by_category(filters[:categories], "quartenary", { 'not_in': ["curso"] }).by_persona(user.personas_quartenary_name).active.order_by_score.limit(count_quartenary_persona)

      Event.union(events_for_primary_persona, events_for_secondary_persona, events_for_tertiary_persona, events_for_quartenary_persona).includes(:place).order_by_date.limit(13)
    }

  scope "order_by_score", -> {
          order("(personas -> 'primary' ->> 'score')::numeric DESC")
        }

  scope "in_days", ->(ocurrences) {
          return nil unless ocurrences

          if ocurrences.include?("hoje") && ocurrences.include?("amanhã")
            where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) BETWEEN ? AND ?", DateTime.now.yday, DateTime.now.yday + 1)
          elsif ocurrences.include? "hoje"
            where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) = ?", DateTime.now.yday)
          elsif ocurrences.include? "amanhã"
            where("date_part('doy', (ocurrences -> 'dates' ->> 0)::timestamptz) = ?", DateTime.now.yday + 1)
          end
        }

  scope "order_by_date", ->(direction = "ASC") {
          case direction
          when "ASC"
            order("(ocurrences -> 'dates' ->> 0) ASC")
          when "DESC"
            order("(ocurrences -> 'dates' ->> 0) DESC")
          end
        }

  scope "by_persona", ->(persona, position = "primary") {
          where("((personas ->> 'outlier') IS NULL OR (personas ->> 'outlier') = 'false') AND (personas -> ? ->> 'name') = ?", position, persona)
        }

  scope "by_category", ->(category, position = "primary", options = { 'not_in': [] }) {
          if options[:not_in].empty?
            where("(categories -> :position ->> 'name') IN (:category) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false')", { category: category, position: position })
          else
            where("(categories -> :position ->> 'name') NOT IN (:notin) AND (categories -> :position ->> 'name') IN (:category) AND ((personas -> 'outlier') IS NULL OR (personas -> 'outlier') = 'false')", { category: category, position: position, notin: options[:not_in] })
          end
        }

  scope "active", -> {
          where("(ocurrences -> 'dates' ->> 0)::timestamptz > ?", DateTime.now - 1)
        }

  scope "with_low_score", ->(feature) {
          case feature
          when :personas
            where("(personas -> 'primary' ->> 'score')::numeric < 0.51")
          when :categories
            where("(categories -> 'primary' ->> 'score')::numeric < 0.51")
          end
        }

  scope "not_retrained", -> {
          where("(categories -> 'primary' ->> 'score')::numeric < 0.90 OR (personas -> 'primary' ->> 'score')::numeric < 0.90")
        }

  def personas_primary_name
    self.personas["primary"]["name"]
  end

  def personas_primary_name=(value)
    self.personas["primary"]["name"] = value
  end

  def personas_secondary_name
    self.personas["secondary"]["name"]
  end

  def personas_secondary_name=(value)
    self.personas["secondary"]["name"] = value
  end

  def personas_primary_score
    self.personas["primary"]["score"]
  end

  def personas_primary_score=(value)
    self.personas["primary"]["score"] = value
  end

  def personas_secondary_score
    self.personas["secondary"]["score"]
  end

  def personas_secondary_score=(value)
    self.personas["secondary"]["score"] = value
  end

  def categories_primary_name
    self.categories["primary"]["name"]
  end

  def categories_primary_name=(value)
    self.categories["primary"]["name"] = value
  end

  def categories_secondary_name
    self.categories["secondary"]["name"]
  end

  def categories_secondary_name=(value)
    self.categories["secondary"]["name"] = value
  end

  def categories_primary_score
    self.categories["primary"]["score"]
  end

  def categories_primary_score=(value)
    self.categories["primary"]["score"] = value
  end

  def categories_secondary_score
    self.categories["secondary"]["score"]
  end

  def categories_secondary_score=(value)
    self.categories["secondary"]["score"] = value
  end

  def personas_outlier
    self.personas["outlier"]
  end

  def personas_outlier=(value)
    self.personas["outlier"] = value
  end

  def categories_outlier
    self.categories["outlier"]
  end

  def categories_outlier=(value)
    self.categories["outlier"] = value
  end

  def neighborhood
    self.geographic["neighborhood"]
  end

  def neighborhood=(value)
    self.geographic["neighborhood"] = value
  end

  def cover_url
    if self.cover.attached?
      rails_blob_path(self.cover, disposition: "attachment", only_path: true)
    end
  end

  def url
    return event_path(self)
  end

  def first_day_time
    return self.ocurrences["dates"].first
  end

  def day_of_week
    Alegreme::Dates.get_next_day_occur_human_readable(self)
  end

  def datetimes
    datetimes = []

    self.ocurrences["dates"].each_with_index do |date, index|
      datetimes << DateTime.parse(date).strftime("%Y-%m-%d %H:%M:%S")
    end

    return datetimes
  end

  private

  def destroy_entries
    users = User.where id: self.saved_by

    users.each do |user|
      user.taste["events"]["saved"].delete self.id
      user.taste["events"]["total_saves"] -= 1
    end
  end
end
