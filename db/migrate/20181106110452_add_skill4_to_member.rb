class AddSkill4ToMember < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :skill4, :string
  end
end
