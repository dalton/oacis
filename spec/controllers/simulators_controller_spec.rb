require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SimulatorsController do

  # This should return the minimal set of attributes required to create a valid
  # Simulator. As you add validations to Simulator, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name:"simulator_A",
      parameter_definitions: {
        "L" => {"type" => "Integer"},
        "T" => {"type" => "Float"}
      },
      command: "~/path_to_simulator_A",
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SimulatorsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all simulators as @simulators" do
      simulator = Simulator.create! valid_attributes
      get :index, {}, valid_session
      response.should be_success
      assigns(:simulators).should eq([simulator])
    end
  end

  describe "GET show" do

    before(:each) do
      @simulator = FactoryGirl.create(:simulator,
                                      parameter_sets_count: 3, runs_count: 0,
                                      analyzers_count: 3, run_analysis: false,
                                      parameter_set_queries_count: 1
                                      )
    end

    it "assigns the requested simulator as @simulator" do
      get :show, {:id => @simulator.to_param}, valid_session
      response.should be_success
      assigns(:simulator).should eq(@simulator)
      assigns(:param_sets).should eq(@simulator.parameter_sets)
      assigns(:analyzers).should eq(@simulator.analyzers)
      assigns(:query_id).should be_nil
      assigns(:query_list).should have(1).items
    end

    context "when 'query_id' parameter is given" do

      before(:each) do
        @query_id = @simulator.parameter_set_queries.first.id
        params = {id: @simulator.to_param, query_id: @query_id}
        get :show, params, valid_session
      end

      it "when 'query_id' is specified, show the list of ParameterSets spec"

      it "assigns 'query_id' variable" do
        assigns(:query_id).should eq(@query_id.to_s)
      end
    end

    it "paginates the list of parameters" do
      simulator = FactoryGirl.create(:simulator, :parameter_sets_count => 30, :runs_count => 0)
      get :show, {:id => simulator.to_param, :page => 1}
      response.should be_success
      assigns(:param_sets).to_a.size.should == 25  # to_a is necessary since #count ignores the limit
    end
  end

  describe "GET new" do
    it "assigns a new simulator as @simulator" do
      get :new, {}, valid_session
      assigns(:simulator).should be_a_new(Simulator)
    end
  end

  # describe "GET edit" do
  #   it "assigns the requested simulator as @simulator" do
  #     simulator = Simulator.create! valid_attributes
  #     get :edit, {:id => simulator.to_param}, valid_session
  #     assigns(:simulator).should eq(simulator)
  #   end
  # end

  describe "POST create" do
    describe "with valid params" do

      before(:each) do
        definitions = [
          {"name" => "param1", "type" => "Integer"},
          {"name" => "param2", "type" => "Float"}
        ]
        simulator = {name: "simulatorA", command: "echo"}
        @valid_post_parameter = {simulator: simulator, definitions: definitions}
      end

      it "creates a new Simulator" do
        expect {
          post :create, @valid_post_parameter, valid_session
        }.to change(Simulator, :count).by(1)
      end

      it "assigns a newly created simulator as @simulator" do
        post :create, @valid_post_parameter, valid_session
        assigns(:simulator).should be_a(Simulator)
        assigns(:simulator).should be_persisted
      end

      it "redirects to the created simulator" do
        post :create, @valid_post_parameter, valid_session
        response.should redirect_to(Simulator.last)
      end
    end

    describe "with invalid params" do

      it "assigns a newly created but unsaved simulator as @simulator" do
        expect {
          post :create, {simulator: {}}, valid_session
          assigns(:simulator).should be_a_new(Simulator)
        }.to_not change(Simulator, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, {simulator: {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  # describe "PUT update" do
  #   describe "with valid params" do
  #     it "updates the requested simulator" do
  #       simulator = Simulator.create! valid_attributes
  #       # Assuming there are no other simulators in the database, this
  #       # specifies that the Simulator created on the previous line
  #       # receives the :update_attributes message with whatever params are
  #       # submitted in the request.
  #       Simulator.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, {:id => simulator.to_param, :simulator => {'these' => 'params'}}, valid_session
  #     end

  #     it "assigns the requested simulator as @simulator" do
  #       simulator = Simulator.create! valid_attributes
  #       put :update, {:id => simulator.to_param, :simulator => valid_attributes}, valid_session
  #       assigns(:simulator).should eq(simulator)
  #     end

  #     it "redirects to the simulator" do
  #       simulator = Simulator.create! valid_attributes
  #       put :update, {:id => simulator.to_param, :simulator => valid_attributes}, valid_session
  #       response.should redirect_to(simulator)
  #     end
  #   end

  #   describe "with invalid params" do
  #     it "assigns the simulator as @simulator" do
  #       simulator = Simulator.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Simulator.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => simulator.to_param, :simulator => {}}, valid_session
  #       assigns(:simulator).should eq(simulator)
  #     end

  #     it "re-renders the 'edit' template" do
  #       simulator = Simulator.create! valid_attributes
  #       # Trigger the behavior that occurs when invalid params are submitted
  #       Simulator.any_instance.stub(:save).and_return(false)
  #       put :update, {:id => simulator.to_param, :simulator => {}}, valid_session
  #       response.should render_template("edit")
  #     end
  #   end
  # end

  # describe "DELETE destroy" do
  #   it "destroys the requested simulator" do
  #     simulator = Simulator.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => simulator.to_param}, valid_session
  #     }.to change(Simulator, :count).by(-1)
  #   end

  #   it "redirects to the simulators list" do
  #     simulator = Simulator.create! valid_attributes
  #     delete :destroy, {:id => simulator.to_param}, valid_session
  #     response.should redirect_to(simulators_url)
  #   end
  # end

end
