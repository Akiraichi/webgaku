class CreateMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :members do |t|
      t.string :name
      t.string :yomi
      t.string :comment
      t.string :position
      t.string :facebook
      t.string :twitter
      t.string :image_url
      t.timestamps
    end
  end
end
