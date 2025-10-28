class Users::SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    super
  end

  def destroy
    super
  end

  # Rails 7.1対応
  def index
    redirect_to root_path
  end

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
