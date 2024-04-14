class AboutPagesController < ApplicationController
    def show
      @about_page = AboutPage.first
    end
  end