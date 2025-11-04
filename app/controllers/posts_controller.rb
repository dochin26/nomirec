class PostsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :autocomplete ]
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :check_owner, only: [ :edit, :update, :destroy ]

  POST_COUNT = 10

  def index
    @api_key = Rails.application.credentials.dig(:googlemaps, :api_key)
    @q = Post.ransack(params[:q])
    @posts = @q.result(distinct: true).includes(:shop, shop: [ :sakes, :foods, :shop_places ]).page(params[:page]).per(POST_COUNT)

    gon.addresses = @addresses
    end

  def new
    @post = Post.new
    @post.build_shop
    @post.shop.sakes.build
    @post.shop.foods.build
    @post.shop.shop_places.build
  end

  def show
    @address = @post.shop.shop_places.pluck(:address).to_s
    gon.addresses = @address
  end

  def edit
    @post.shop.shop_places.build if @post.shop.shop_places.empty?

    # 編集時に既存の酒・食べ物をスペース区切りで表示
    @post.shop.sake_names_input = @post.shop.sakes.pluck(:name).join(" ")
    @post.shop.food_names_input = @post.shop.foods.pluck(:name).join(" ")

    @address = @post.shop.shop_places.pluck(:address).to_s
    gon.addresses = @address
  end

  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        # タグの更新
        update_shop_tags(@post.shop, params[:post][:shop_attributes])

        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.prepend("posts_list", partial: "posts/post", locals: { post: @post }),
            turbo_stream.update("post_modal", ""),
            turbo_stream.append("toast_container", partial: "shared/toast", locals: { message: t("posts.created"), type: "success" })
          ]
        }
        format.html {
          flash[:success] = t("posts.created")
          redirect_to posts_path
        }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("post_modal", partial: "posts/modal_form", locals: { post: @post })
        }
        format.html {
          flash.now[:danger] = t("posts.create_failed")
          render :new, status: :unprocessable_entity
        }
      end
    end
  end

  def update
    if @post.update(post_params)
      # タグの更新
      update_shop_tags(@post.shop, params[:post][:shop_attributes])
      flash[:success] = t("posts.updated")
      redirect_to posts_path
    else
      flash.now[:danger] = t("posts.update_failed")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: t("posts.destroyed")
  rescue => e
    redirect_to posts_path, alert: t("posts.destroy_failed", error: e.message)
  end

  def autocomplete
    query = "%#{params[:q]}%"
    results = [
      search_shops(query),
      search_sakes(query),
      search_foods(query),
      search_addresses(query)
    ].flatten

    @results = results.uniq { |r| [ r[:type], r[:name], r[:address] ] }.first(10)

    respond_to do |format|
      format.html { render partial: "posts/autocomplete_results", locals: { results: @results } }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def check_owner
    redirect_to posts_path, alert: t("posts.access_denied") unless @post.user == current_user
  end

  def update_shop_tags(shop, shop_params)
    return unless shop_params

    # 酒のタグを更新
    if shop_params[:sake_names_input]
      shop.update_sake_tags(shop_params[:sake_names_input])
    end

    # 料理のタグを更新
    if shop_params[:food_names_input]
      shop.update_food_tags(shop_params[:food_names_input])
    end
  end

  def post_params
    params.require(:post).permit(
      :comment,
      :shop_id,
      :body_image,
      shop_attributes: [
        :id,
        :name,
        :introduction,
        :sake_names_input,
        :food_names_input,
        shop_places_attributes: [ :id, :address, :_destroy ]
      ]
    )
  end

  # オートコンプリート検索メソッド
  def search_shops(query)
    Shop.joins(:posts)
      .where("shops.name LIKE ?", query)
      .select("DISTINCT shops.id, shops.name")
      .order("shops.name ASC")
      .limit(10)
      .map { |shop| { type: "shop", name: shop.name, value: shop.name } }
  end

  def search_sakes(query)
    Sake.where("sakes.name LIKE ?", query)
      .includes(shops: [ :shop_places, :posts ])
      .order("sakes.name ASC")
      .limit(10)
      .flat_map { |sake| build_item_results(sake, "sake") }
  end

  def search_foods(query)
    Food.where("foods.name LIKE ?", query)
      .includes(shops: [ :shop_places, :posts ])
      .order("foods.name ASC")
      .limit(10)
      .flat_map { |food| build_item_results(food, "food") }
  end

  def search_addresses(query)
    ShopPlace.joins(shop: :posts)
      .where("shop_places.address LIKE ?", query)
      .includes(:shop)
      .select("DISTINCT shop_places.id, shop_places.address, shop_places.shop_id")
      .order("shop_places.address ASC")
      .limit(10)
      .map { |place| { type: "address", name: place.shop.name, address: place.address, value: place.address } }
  end

  def build_item_results(item, type)
    item.shops.flat_map do |shop|
      next [] unless shop.posts.any?

      shop.shop_places.map do |place|
        {
          type: type,
          name: shop.name,
          address: place.address,
          value: item.name,
          "#{type}_name".to_sym => item.name
        }
      end
    end.compact
  end
end
