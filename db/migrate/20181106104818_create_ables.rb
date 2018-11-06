class CreateAbles < ActiveRecord::Migration[5.0]
  def change
    create_table :ables do |t|
      t.string :name, foreign_key: true
      t.string :able_name

      t.timestamps
    end
  end
end
