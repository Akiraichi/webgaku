class AddSkill1ToMember < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :skill1, :string
  end
end
