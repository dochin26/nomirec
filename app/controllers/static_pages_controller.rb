class StaticPagesController < ApplicationController
  include OgpHelper
  
  def index
    set_index_meta_tags
  end

  def test
  end

  def terms
  end

  def privacy
  end
end
