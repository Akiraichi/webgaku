class AddSkill2ToMember < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :skill2, :string
  end
end
