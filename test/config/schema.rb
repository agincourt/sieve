ActiveRecord::Schema.define do
  create_table "test_objects", :force => true do |t|
    t.string :name
    t.datetime :created_at
  end
end