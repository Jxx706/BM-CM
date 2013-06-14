class FlowsController < ApplicationController
  
  def home
    @title = "Flujos"
  end
  
  #It shows all flows
  def index
  end

  #It shows just one flow
  def show
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It creates a new flow and save it in the database
  def create
  end

  #New flow
  def new #Create
    @title = 'Nuevo flujo'
  end

  def create #Post
  end

  #It saves changes to one flow in the database
  def update #POST
  end

  #It edits the info of a flow
  def edit #GET
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It destroys one flow (i.e. removes it from the database)
  def destroy
    @flow.destroy
  end
end
