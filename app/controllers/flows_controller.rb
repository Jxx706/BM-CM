class FlowsController < ApplicationController
  
  def home #(flows_home_path)
    @title = "Flujos"
  end
  
  #It shows all flows
  #(flows -- GET /flows)
  def index
    @flows = nil#
  end

  #It shows just one flow (flow -- GET /flow/:id)
  def show
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It creates a new flow and save it in the database
  #(POST /flows)
  def create
  end

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
  end

  #It saves changes to one flow in the database
  def update #(PUT /flows/:id)
  end

  #It edits the info of a flow
  def edit #(edit_flow -- GET /flows/:id/edit)
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It destroys one flow (i.e. removes it from the database)
  #(DELETE /flows/:id)
  def destroy
    @flow.destroy
  end
end
