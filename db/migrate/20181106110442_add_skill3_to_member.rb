class AddSkill3ToMember < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :skill3, :string
  end
end
