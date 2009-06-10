ActiveRecord::Schema.define do

  create_table "houses", :force => true do |t|
    
    t.string   "home_address_1",             :limit => 50
    t.string   "home_address_2",             :limit => 50
    t.string   "home_address_3",             :limit => 50
    t.string   "home_city",                  :limit => 50
    t.string   "home_state",                 :limit => 2
    t.string   "home_province",              :limit => 20
    t.string   "home_zip",                   :limit => 20
    t.string   "home_country",               :limit => 50

    t.string   "work_address_1",             :limit => 50
    t.string   "work_address_2",             :limit => 50
    t.string   "work_address_3",             :limit => 50
    t.string   "work_city",                  :limit => 50
    t.string   "work_state",                 :limit => 2
    t.string   "work_province",              :limit => 20
    t.string   "work_zip",                   :limit => 20
    t.string   "work_country",               :limit => 50
    
  end

end