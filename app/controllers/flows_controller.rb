class FlowsController < ApplicationController
  
  #NOTE TO SELF: current_user contains the User who owns the flows
  #NOTE TO SELF: This is a preliminary version where the Flows are independent of the users. So, 
  #it's very likely that most of this controllers change (maybe a lot!) anytime soon.

  def home #(flows_home_path)
    @title = "Flujos"
  end
  
  #It shows all flows
  #(flows -- GET /flows)
  def index
    @title = "Todos los flujos"
    @flows = Flows.all#
  end

  #It shows just one flow (flow -- GET /flow/:id)
  def show
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It creates a new flow and save it in the database
  #(POST /flows)
  def create
    @flow = Flow.new(params[:flow])

    if @flow.save
      flash[:success] = "¡Flujo creado!"
      redirect_to @flow
    else
      @title = "Nuevo flujo"
      render 'new'
  end

  #New flow
  def new #(new_flow -- GET /flows/new)
    @title = 'Nuevo flujo'
  end

  #It saves changes to one flow in the database
  def update #(PUT /flows/:id)
    @flow = Flow.find(params[:id])

    if @flow.update_attributes(params[:flow])
      flash[:success] = "Flujo actualizado con éxito."
      redirect_to @flow
    else
      @title = "Editar flujo."
      render 'edit' #Comes back to the edit page 
    end
  end

  #It edits the info of a flow
  def edit #(edit_flow -- GET /flows/:id/edit)
    @title = "Editar flujo"
    @flow = Flow.find(params[:id]) #Retrieves the info of the flow instance with id = :id
  end

  #It destroys one flow (i.e. removes it from the database)
  #(DELETE /flows/:id)
  def destroy
    @flow = Flow.find(params[:id])
    @flow.destroy
    flash[:success] = "Flujo destruido con éxito."

    redirect_to flows_path #Indexes all of the flows again.
  end

  #Download this file.
  def download_file
  end

  private
  #private functions
end
