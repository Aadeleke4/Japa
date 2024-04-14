class PagesController < ApplicationController
  def about
    @about_page = Page.find_by(page_type: :about)
  end

  def contact
    @contact_page = Page.find_by(page_type: :contact)
  end
end