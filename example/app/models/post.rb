class Post < ActiveRecord::Base
  belongs_to :category
  
  def categories
    category    = self.category
    categories  = []
    
    while category.present?
      categories << category
      category = category.category
    end
    
    categories.reverse
  end
  
  def to_s
    title
  end
end
