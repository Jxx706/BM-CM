class PagesController < ApplicationController
  
  #Home page controller
  def home
  	@title = "Home" #Page title
  end

  #Pre-conditions and diverse information page controller
  def get_started
  	@title= "Antes de empezar..." #Page title
  end
end
