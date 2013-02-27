class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title
      t.string :slug
      
      t.string :category_id # Can have a category as a parent
      
      t.timestamps
    end
  end
end
