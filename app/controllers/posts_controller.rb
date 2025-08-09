class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index ]

  def index
    @posts = Post.includes(:user)
  end

  def new
    @post = Post.new
    @post.build_shop
    @post.shop.sakes.build
    @post.shop.foods.build
  end

  def show
    @posts = Post.includes(:user)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, success: "Post created successfully."
    else
      flash.now[:danger] = "Failed to create post."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.require(:post).permit(
      :comment,
      :shop_id,
      shop_attributes: [
        :name,
        :introduction,
        sakes_attributes: [:name],
        foods_attributes: [:name]
      ]
    )
  end
end
