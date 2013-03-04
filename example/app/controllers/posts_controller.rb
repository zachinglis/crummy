class PostsController < ApplicationController
  add_crumb "Posts", :posts_url, :except => [:new]

  def index
    @posts = Post.all
  end

  def show
    @post = Post.find params[:id]
    
    @post.categories.each do |category|
      add_crumb category.title, "#"
    end
  end
  
  def new
    add_crumb "Forever Alone"
  end
end
