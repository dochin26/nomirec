# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_08_08_235204) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "foods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_foods_on_name", unique: true
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "shop_id"
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_posts_on_shop_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "sakes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sakes_on_name", unique: true
  end

  create_table "shop_foods", force: :cascade do |t|
    t.bigint "shop_id", null: false
    t.bigint "food_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id"], name: "index_shop_foods_on_food_id"
    t.index ["shop_id", "food_id"], name: "index_shop_foods_on_shop_id_and_food_id", unique: true
    t.index ["shop_id"], name: "index_shop_foods_on_shop_id"
  end

  create_table "shop_sakes", force: :cascade do |t|
    t.bigint "shop_id", null: false
    t.bigint "sake_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sake_id"], name: "index_shop_sakes_on_sake_id"
    t.index ["shop_id", "sake_id"], name: "index_shop_sakes_on_shop_id_and_sake_id", unique: true
    t.index ["shop_id"], name: "index_shop_sakes_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.string "introduction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "shop_foods", "foods"
  add_foreign_key "shop_foods", "shops"
  add_foreign_key "shop_sakes", "sakes"
  add_foreign_key "shop_sakes", "shops"
end
