class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def verify  # for Cert verification
    render file: Rails.root.join("app", request.original_url.split('/').last)
  end
end
