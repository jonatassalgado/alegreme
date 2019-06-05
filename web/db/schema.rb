# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_06_032423) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "artifacts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendars_events", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "calendar_id", null: false
    t.index ["calendar_id", "event_id"], name: "index_calendars_events_on_calendar_id_and_event_id", unique: true
    t.index ["event_id", "calendar_id"], name: "index_calendars_events_on_event_id_and_calendar_id", unique: true
  end

  create_table "categories_events", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id", "event_id"], name: "index_categories_events_on_category_id_and_event_id", unique: true
    t.index ["event_id", "category_id"], name: "index_categories_events_on_event_id_and_category_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.jsonb "theme", default: {"name"=>nil, "score"=>nil, "outlier"=>nil}, null: false
    t.jsonb "personas", default: {"outlier"=>nil, "primary"=>{"name"=>nil, "score"=>nil}, "secondary"=>{"name"=>nil, "score"=>nil}}, null: false
    t.jsonb "categories", default: {"outlier"=>nil, "primary"=>{"name"=>nil, "score"=>nil}, "secondary"=>{"name"=>nil, "score"=>nil}}, null: false
    t.jsonb "kinds", default: [], null: false
    t.jsonb "tags", default: {"things"=>[], "features"=>[], "activities"=>[]}, null: false
    t.jsonb "geographic", default: {"cep"=>nil, "city"=>nil, "latlon"=>[], "address"=>nil, "neighborhood"=>nil}, null: false
    t.jsonb "ocurrences", default: {"dates"=>[]}, null: false
    t.jsonb "details", default: {"name"=>nil, "prices"=>[], "source_url"=>nil, "description"=>nil}, null: false
    t.jsonb "entries", default: {"liked_by"=>[], "saved_by"=>[], "viewed_by"=>[], "disliked_by"=>[], "total_likes"=>0, "total_saves"=>0, "total_views"=>0, "total_dislikes"=>0}, null: false
    t.jsonb "ml_data", default: {"adjs"=>[], "freq"=>[], "nouns"=>[], "verbs"=>[], "stemmed"=>nil, "cleanned"=>nil}, null: false
    t.jsonb "similar_to", default: [], null: false
    t.jsonb "image_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "place_id"
    t.index "((tags -> 'activities'::text))", name: "index_events_on_tags_activities", using: :gin
    t.index "((tags -> 'features'::text))", name: "index_events_on_tags_features", using: :gin
    t.index "((tags -> 'things'::text))", name: "index_events_on_tags_things", using: :gin
    t.index ["categories"], name: "index_events_on_categories", using: :gin
    t.index ["details"], name: "index_events_on_details", using: :gin
    t.index ["entries"], name: "index_events_on_entries", using: :gin
    t.index ["geographic"], name: "index_events_on_geographic", using: :gin
    t.index ["image_data"], name: "index_events_on_image_data", using: :gin
    t.index ["kinds"], name: "index_events_on_kinds", using: :gin
    t.index ["ml_data"], name: "index_events_on_ml_data", using: :gin
    t.index ["ocurrences"], name: "index_events_on_ocurrences", using: :gin
    t.index ["personas"], name: "index_events_on_personas", using: :gin
    t.index ["place_id"], name: "index_events_on_place_id"
    t.index ["similar_to"], name: "index_events_on_similar_to", using: :gin
    t.index ["tags"], name: "index_events_on_tags", using: :gin
    t.index ["theme"], name: "index_events_on_theme", using: :gin
  end

  create_table "events_organizers", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "organizer_id", null: false
    t.index ["event_id", "organizer_id"], name: "index_events_organizers_on_event_id_and_organizer_id", unique: true
    t.index ["organizer_id", "event_id"], name: "index_events_organizers_on_organizer_id_and_event_id", unique: true
  end

  create_table "organizers", force: :cascade do |t|
    t.string "name"
    t.string "source_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "places", force: :cascade do |t|
    t.jsonb "details", default: {"name"=>nil}, null: false
    t.jsonb "geographic", default: {"cep"=>nil, "city"=>nil, "latlon"=>[], "address"=>nil, "neighborhood"=>nil}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["details"], name: "index_places_on_details", using: :gin
    t.index ["geographic"], name: "index_places_on_geographic", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "features", default: {"geographic"=>{"home"=>{"cep"=>nil, "city"=>nil, "latlon"=>[], "address"=>nil, "neighborhood"=>nil}, "current"=>{"cep"=>nil, "city"=>nil, "latlon"=>[], "address"=>nil, "timestamp"=>nil, "neighborhood"=>nil}, "assortment"=>{"finished"=>nil, "finished_at"=>nil}}, "demographic"=>{"age"=>nil, "name"=>nil, "gender"=>nil, "with_kids"=>nil, "assortment"=>{"finished"=>nil, "finished_at"=>nil}, "profession"=>nil, "university"=>nil, "income_level"=>nil, "marital_status"=>nil, "education_level"=>nil}, "psychographic"=>{"personas"=>{"primary"=>{"name"=>nil, "score"=>nil}, "tertiary"=>{"name"=>nil, "score"=>nil}, "secondary"=>{"name"=>nil, "score"=>nil}, "assortment"=>{"finished"=>nil, "finished_at"=>nil}, "quartenary"=>{"name"=>nil, "score"=>nil}}, "activities"=>{"names"=>[], "assortment"=>{"finished"=>nil, "finished_at"=>nil}}}}, null: false
    t.jsonb "taste", default: {"events"=>{"liked"=>[], "saved"=>[], "viewed"=>[], "disliked"=>[], "total_likes"=>0, "total_saves"=>0, "total_views"=>0, "total_dislikes"=>0}}, null: false
    t.boolean "admin", default: false
    t.index "((((features -> 'psychographic'::text) -> 'personas'::text) -> 'primary'::text))", name: "index_users_on_features_psychographic_personas_primary", using: :gin
    t.index "((((features -> 'psychographic'::text) -> 'personas'::text) -> 'quartenary'::text))", name: "index_users_on_features_psychographic_personas_quartenary", using: :gin
    t.index "((((features -> 'psychographic'::text) -> 'personas'::text) -> 'secondary'::text))", name: "index_users_on_features_psychographic_personas_secondary", using: :gin
    t.index "((((features -> 'psychographic'::text) -> 'personas'::text) -> 'tertiary'::text))", name: "index_users_on_features_psychographic_personas_tertiary", using: :gin
    t.index "(((features -> 'psychographic'::text) -> 'activities'::text))", name: "index_users_on_features_psychographic_activities", using: :gin
    t.index "(((features -> 'psychographic'::text) -> 'personas'::text))", name: "index_users_on_features_psychographic_personas", using: :gin
    t.index "((features -> 'demographic'::text))", name: "index_users_on_features_demographic", using: :gin
    t.index "((features -> 'geographic'::text))", name: "index_users_on_features_geographic", using: :gin
    t.index "((features -> 'psychographic'::text))", name: "index_users_on_features_psychographic", using: :gin
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["features"], name: "index_users_on_features", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["taste"], name: "index_users_on_taste", using: :gin
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "places"
end
