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
      parameter_definitions_attributes: [
        { key: "L", type: "Integer"},
        { key: "T", type: "Float"}
      ],
      command: "~/path_to_simulator_A"
    }
  end

  describe "GET index" do

    it "assigns all simulators as @simulators" do
      simulator = Simulator.create! valid_attributes
      get :index, params: {}
      expect(response).to be_successful
      expect(assigns(:simulators)).to eq([simulator])
    end

    it "@simulators are sorted by the position" do
      simulators = FactoryBot.create_list(:simulator, 3)
      simulators.first.update_attribute(:position, 2)
      simulators.last.update_attribute(:position, 0)
      sorted = simulators.sort_by {|sim| sim.position }
      get :index, params: {}
      expect(assigns(:simulators)).to eq sorted
    end
  end

  describe "GET show" do

    before(:each) do
      @simulator = FactoryBot.create(:simulator,
                                      parameter_sets_count: 5, runs_count: 0,
                                      analyzers_count: 3, run_analysis: false,
                                      parameter_set_filters_count: 5
                                      )
    end

    it "assigns the requested simulator as @simulator" do
      get :show, params: {id: @simulator.to_param}
      expect(response).to be_successful
      expect(assigns(:simulator)).to eq(@simulator)
      expect(assigns(:analyzers)).to match_array(@simulator.analyzers)
    end

    it "returns success for json format" do
      get :show, params: {id: @simulator, format: :json}
      expect(response).to be_successful
    end

    it "assigns filter when param[:filter] is given" do
      f = @simulator.parameter_set_filters.first
      get :show, params: {id: @simulator.to_param, filter: f}
      expect(response).to be_successful
      expect(assigns(:filter)).to eq f
    end

    it "assigns filter when param[:q] is given" do
      get :show, params: {id: @simulator.to_param, q: [["T","gte",3.5]].to_json}
      expect(response).to be_successful
      f = assigns(:filter)
      expect(f.conditions).to eq [["T","gte",3.5]]
    end
  end

  describe "GET new" do
    it "assigns a new simulator as @simulator" do
      get :new, params: {}
      expect(assigns(:simulator)).to be_a_new(Simulator)
    end

    it "executable_on is not empty by default" do
      h = FactoryBot.create(:host)
      get :new, params: {}
      expect(assigns(:simulator).executable_on.size).to be 1
    end

    it "@duplicating_simulator is nil" do
      get :new, params: {}
      expect(assigns(:duplicating_simulator)).to be_nil
    end
  end

  describe "GET duplicate" do

    before(:each) do
      @simulator = FactoryBot.create(:simulator, parameter_sets_count: 0, analyzers_count: 2)
    end

    it "assigns a new simulator as @simulator" do
      get :duplicate, params: {id: @simulator}
      expect(assigns(:simulator)).to be_a_new(Simulator)
      expect(assigns(:simulator).name).to eq @simulator.name
      expect(assigns(:simulator).command).to eq @simulator.command
      keys = @simulator.parameter_definitions.map(&:key)
      expect(assigns(:simulator).parameter_definitions.map(&:key)).to eq keys
    end

    it "assigns the original simulator to @duplicating_simulator" do
      get :duplicate, params: {id: @simulator}
      expect(assigns(:duplicating_simulator)).to eq @simulator
    end

    it "assigns analyzers of the original simulator to @copied_analyzers" do
      get :duplicate, params: {id: @simulator}
      expect(assigns(:copied_analyzers)).to match_array(@simulator.analyzers)
    end
  end

  describe "GET export_runs" do

    before(:each) do
      @simulator = FactoryBot.create(:simulator, parameter_sets_count: 3, runs_count: 2)
    end

    it "assigns a new simulator as @simulator" do
      get :export_runs, params: {id: @simulator}, format: :csv
      expect(response.header['Content-Type']).to include 'text/csv'
      expect(response.body).to eq @simulator.runs_csv(@simulator.runs)
    end
  end

  describe "GET edit" do
    it "assigns the requested simulator as @simulator" do
      simulator = Simulator.create! valid_attributes
      get :edit, params: {:id => simulator.to_param}
      expect(assigns(:simulator)).to eq(simulator)
    end
  end

  describe "POST create" do
    describe "with valid params" do

      before(:each) do
        host = FactoryBot.create(:host)
        definitions = [
          {key: "param1", type: "Integer"},
          {key: "param2", type: "Float"}
        ]
        simulator = {
          name: "simulatorA", command: "echo", support_input_json: "0",
          pre_process_script: "preprocess.sh",
          local_pre_process_script: "local_preprocess.sh",
          support_mpi: "0", support_omp: "1",
          sequential_seed: "1",
          parameter_definitions_attributes: definitions,
          executable_on_ids: [host.id.to_s]
        }
        @valid_post_parameter = {simulator: simulator}
      end

      it "creates a new Simulator" do
        expect {
          post :create, params: @valid_post_parameter
        }.to change(Simulator, :count).by(1)
      end

      it "assigns attributes of newly created Simulator" do
        post :create, params: @valid_post_parameter
        sim = Simulator.order_by(id: :asc).last
        expect(sim.name).to eq "simulatorA"
        expect(sim.command).to eq "echo"
        expect(sim.support_input_json).to be_falsey
        expect(sim.pre_process_script).to eq "preprocess.sh"
        expect(sim.local_pre_process_script).to eq "local_preprocess.sh"
        expect(sim.parameter_definition_for("param1").type).to eq "Integer"
        expect(sim.parameter_definition_for("param2").type).to eq "Float"
        expect(sim.support_mpi).to be_falsey
        expect(sim.support_omp).to be_truthy
        expect(sim.sequential_seed).to be_truthy
      end

      it "assigns a newly created simulator as @simulator" do
        post :create, params: @valid_post_parameter
        expect(assigns(:simulator)).to be_a(Simulator)
        expect(assigns(:simulator)).to be_persisted
      end

      it "redirects to the created simulator" do
        post :create, params: @valid_post_parameter
        expect(response).to redirect_to(Simulator.order_by(id: :asc).last)
      end
    end

    describe "when duplicating a simulator" do

      before(:each) do
        @sim = FactoryBot.create(:simulator, parameter_sets_count: 0, analyzers_count: 2)
        definitions = @sim.parameter_definitions.map {|pd| {key: pd.key, type: pd.type} }
        simulator = {
          name: "duplicated", command: @sim.command, support_input_json: "0",
          support_mpi: "0", support_omp: "1",
          parameter_definitions_attributes: definitions
        }
        @valid_post_parameter = {
          simulator: simulator,
          duplicating_simulator: @sim.id.to_s, copied_analyzers: @sim.analyzers.map(&:id).map(&:to_s)
        }
      end

      it "creates a new Simulator" do
        expect {
          post :create, params: @valid_post_parameter
        }.to change(Simulator, :count).by(1)
      end

      it "creates a new Analyzer" do
        expect {
          post :create, params: @valid_post_parameter
        }.to change(Analyzer, :count).by(2)
      end

      it "does not create a new analyzer when copied_analyzers is nil" do
        @valid_post_parameter[:copied_analyzers] = nil
        expect {
          post :create, params: @valid_post_parameter
        }.to_not change(Analyzer, :count)
      end

      it "does not create a new Analyzer when simulator is not created" do
        @valid_post_parameter[:simulator][:name] = @sim.name
        expect {
          post :create, params: @valid_post_parameter
        }.to_not change(Analyzer, :count)
      end

      it "assigns @duplicating_simulator and @copied_analyzers when invalid param is given" do
        @valid_post_parameter[:simulator][:name] = @sim.name
        # remove one in order to verify the checkboxes are maintained when error is happened
        @valid_post_parameter[:copied_analyzers].shift

        post :create, params: @valid_post_parameter
        expect(assigns(:duplicating_simulator)).to eq @sim
        expect(assigns(:copied_analyzers).size).to eq 1
      end
    end

    describe "with invalid params" do

      it "assigns a newly created but unsaved simulator as @simulator" do
        expect {
          post :create, params: {simulator: {}}
          expect(assigns(:simulator)).to be_a_new(Simulator)
        }.to_not change(Simulator, :count)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        post :create, params: {simulator: {}}
        expect(response).to render_template("new")
      end
    end

    describe "with no permitted params" do

      it "create new simulator but no permitted params are not saved" do
        invalid_params = valid_attributes.update(position: 100)
                                          .update(default_host_parameters: {"host_id"=>{"param1"=>123}})
                                          .update(default_mpi_procs: {"host_id"=>12345})
                                          .update(default_omp_threads: {"host_id"=>54321})
                                          .update(invalid: 1)
        expect {
          post :create, params: {simulator: invalid_params, invalid: 1}
        }.to change {Simulator.count}.by(1)
        sim = Simulator.order_by(id: :asc).last
        expect(sim.position).not_to eq 100
        expect(sim.default_host_parameters).not_to include({"host_id"=>{"param1"=>123}})
        expect(sim.default_mpi_procs).not_to include({"host_id"=>12345})
        expect(sim.default_omp_threads).not_to include({"host_id"=>54321})
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do

      before(:each) do
        definitions = [
          {key: "param1", type: "Integer"},
          {key: "param2", type: "Float"}
        ]
        @valid_post_parameter = {
          name: "simulatorA", command: "echo", support_input_json: "0",
          pre_process_script: "preprocess.sh",
          local_pre_process_script: "local_preprocess.sh",
          support_mpi: "0", support_omp: "1",
          sequential_seed: "1",
          parameter_definitions_attributes: definitions
        }
      end

      it "updates the requested simulator" do
        simulator = Simulator.create! valid_attributes
        expect_any_instance_of(Simulator).to receive(:update_attributes).with({'description' => 'yyy zzz'})
        put :update, params: {:id => simulator.to_param, :simulator => {'description' => 'yyy zzz'}}
      end

      it "assigns the requested simulator as @simulator" do
        simulator = Simulator.create! valid_attributes
        put :update, params: {:id => simulator.to_param, :simulator => @valid_post_parameter}
        expect(assigns(:simulator).id).to eq simulator.id
        expect(assigns(:simulator).command).to eq "echo"
        expect(assigns(:simulator).support_input_json).to be_falsey
        expect(assigns(:simulator).pre_process_script).to eq "preprocess.sh"
        expect(assigns(:simulator).local_pre_process_script).to eq "local_preprocess.sh"
        expect(assigns(:simulator).support_mpi).to be_falsey
        expect(assigns(:simulator).support_omp).to be_truthy
        expect(assigns(:simulator).sequential_seed).to be_truthy
      end

      it "redirects to the simulator" do
        simulator = Simulator.create! valid_attributes
        put :update, params: {:id => simulator.to_param, :simulator => @valid_post_parameter}
        expect(response).to redirect_to(simulator)
      end
    end

    describe "with invalid params" do
      it "assigns the simulator as @simulator" do
        simulator = Simulator.create! valid_attributes
        allow_any_instance_of(Simulator).to receive(:save).and_return(false)
        put :update, params: {:id => simulator.to_param, :simulator => {}}
        expect(assigns(:simulator)).to eq(simulator)
      end

      it "re-renders the 'edit' template" do
        simulator = Simulator.create! valid_attributes
        allow_any_instance_of(Simulator).to receive(:save).and_return(false)
        put :update, params: {:id => simulator.to_param, :simulator => {}}
        expect(response).to render_template("edit")
      end
    end

    describe "with no permitted params" do

      before(:each) do
        definitions = [
          {key: "param1", type: "Integer"},
          {key: "param2", type: "Float"}
        ]
        @valid_post_parameter = {
          name: "simulatorA", command: "echo", support_input_json: "0",
          support_mpi: "0", support_omp: "1",
          parameter_definitions_attributes: definitions
        }
      end

      it "update new simulator but no permitted params are not saved" do
        simulator = Simulator.create! valid_attributes
        invalid_params = @valid_post_parameter.update(description: "yyy zzz")
                                              .update(position: 100)
                                              .update(default_host_parameters: {"host_id"=>{"param1"=>123}})
                                              .update(default_mpi_procs: {"host_id"=>12345})
                                              .update(default_omp_threads: {"host_id"=>54321})
                                              .update(invalid: 1)
        post :update, params: {id: simulator.to_param, simulator: invalid_params, invalid: 1}
        expect(assigns(:simulator).description).to eq "yyy zzz"
        expect(assigns(:simulator).position).not_to eq 100
        expect(assigns(:simulator).default_host_parameters).not_to include({"host_id"=>{"param1"=>123}})
        expect(assigns(:simulator).default_mpi_procs).not_to include({"host_id"=>12345})
        expect(assigns(:simulator).default_omp_threads).not_to include({"host_id"=>54321})
      end
    end

    describe "to remove parameter definitions" do

      it "removes the requested parameter defs" do
        simulator = Simulator.create! valid_attributes
        pdef1=simulator.parameter_definitions.first
        pdef2=simulator.parameter_definitions.second
        put :update, params: {:id => simulator.to_param, :simulator => {'parameter_definitions_attributes' => {0=>{"id"=>pdef1.to_param, "_destroy"=>"true"}, 1=>{"id"=>pdef2.to_param, "_destroy"=>"false", "key"=>pdef2.key, "type"=>pdef2.type, "default"=>pdef2.default, "description"=>pdef2.description}}}}
        updated_sim = assigns(:simulator)
        expect(updated_sim.parameter_definitions.size).to eq 1
        expect(updated_sim.parameter_definitions.first.to_param).to eq pdef2.to_param
      end
    end
  end

  describe "DELETE destroy" do

    before(:each) do
      @sim = FactoryBot.create(:simulator, parameter_sets_count: 0)
    end

    it "reduces the number of simulators in default scope" do
      expect {
        delete :destroy, params: {id: @sim.to_param}
      }.to change(Simulator, :count).by(-1)
    end

    it "does not destroy simulator" do
      expect {
        delete :destroy, params: {id: @sim.to_param}
      }.to_not change { Simulator.unscoped.count }
    end

    it "redirects to the simulators list" do
      delete :destroy, params: {id: @sim.to_param}
      expect(response).to redirect_to(simulators_url)
    end
  end

  describe "POST save_filter" do
    before(:each) do
      @sim = FactoryBot.create(:simulator,
                               parameter_sets_count: 1, runs_count: 0)
    end

    context "with valid params" do

      before(:each) do
        @valid_param = {id: @sim.to_param, filter_name: "filter1", q: [['T','gte',4.0], ['L','eq',2]].to_json }
      end

      it "creates a new ParameterSetFilter" do
        expect {
          post :save_filter, params: @valid_param
        }.to change(ParameterSetFilter, :count).by(1)
        f = @sim.reload.parameter_set_filters.first
        expect(f.name).to eq 'filter1'
        expect(f.conditions).to eq [['T','gte',4.0], ['L','eq',2]]
      end

      it "redirects to show with the created parameter_set_filter" do
        post :save_filter, params: @valid_param
        f = @sim.reload.parameter_set_filters.first
        expect(response).to redirect_to(simulator_path(@sim, filter: f.to_param))
      end

      it "overwrites filter when a filter of identical name already exists" do
        f = @sim.parameter_set_filters.create!(name: 'filter1', conditions: [['L','eq',2]])
        expect {
          post :save_filter, params: @valid_param
        }.to_not change(ParameterSetFilter, :count)
        expect(f.reload.conditions).to eq [['T','gte',4.0], ['L','eq',2]]
        expect(response).to redirect_to(simulator_path(@sim, filter: f.to_param))
      end
    end
  end

  describe "GET _find_filter" do

    before(:each) do
      @sim = FactoryBot.create(:simulator)
      @valid_param = {id: @sim.to_param, filter_name: "filter1"}
    end

    it "returns the found filter in JSON" do
      f = @sim.parameter_set_filters.create!(name: 'filter1', conditions: [['L','eq',2]])
      get :_find_filter, params: @valid_param, format: :json
      expect(response.header['Content-Type']).to include 'application/json'
      ret = JSON.parse(response.body)
      expect(ret['name']).to eq 'filter1'
      expect(ret['conditions']).to eq [['L','eq',2]]
    end

    it "returns null in JSON when a matched filter is not found" do
      @sim.parameter_set_filters.create!(name: 'filter2', conditions: [['L','eq',2]])
      get :_find_filter, params: @valid_param, format: :json
      expect(response.header['Content-Type']).to include 'application/json'
      expect(JSON.parse(response.body)).to be_nil
    end
  end

  describe "POST _delete_filter" do

    before(:each) do
      @sim = FactoryBot.create(:simulator)
      f = @sim.parameter_set_filters.create!(name: 'filter1', conditions: [['L','eq',2]])
      @valid_param = {id: @sim.to_param, filter: f.to_param}
    end

    it "deletes a Filter" do
      expect {
        post :_delete_filter, params: @valid_param
      }.to change(ParameterSetFilter, :count).by(-1)
      expect(response).to be_successful
    end

    it "does nothing when the specified Filter is not found" do
      expect {
        post :_delete_filter, params: @valid_param.update(filter: "INVALID_ID")
      }.to_not change(ParameterSetFilter, :count)
      expect(response).to be_successful
    end
  end

  describe "GET _parameter_sets_list" do
    before(:each) do
      @simulator = FactoryBot.create(:simulator,
                                      parameter_sets_count: 30, runs_count: 0,
                                      analyzers_count: 3, run_analysis: false,
                                      parameter_set_filters_count: 5
                                      )
      get :_parameter_sets_list, params: {id: @simulator.to_param, draw: 1, start: 0, length:25 , "order" => {"0" => {"column" => "0", "dir" => "asc"}}}, :format => :json
      @parsed_body = JSON.parse(response.body)
    end

    it "return json format" do
      expect(response.header['Content-Type']).to include 'application/json'
      expect(@parsed_body["recordsTotal"]).to eq 30
      expect(@parsed_body["recordsFiltered"]).to eq 30
    end

    it "paginates the list of parameters" do
      expect(@parsed_body["data"].size).to eq 25
    end

    context "when 'q' parameter is given" do

      before(:each) do
        @simulator = FactoryBot.create(:simulator, parameter_sets_count: 0)
        10.times do |i|
          FactoryBot.create(:parameter_set,
                             simulator: @simulator,
                             runs_count: 0,
                             v: {"L" => i, "T" => i*2.0}
                             )
        end
        f = @simulator.parameter_set_filters.build(conditions: [["L","gte",5]])

        # columns ["id", "progress_rate_cache", "id", "updated_at"] + @param_keys.map {|key| "v.#{key}"} + ["id"]
        get :_parameter_sets_list, params: {id: @simulator.to_param, draw: 1, start: 0, length:25 , "order" => {"0" => {"column" => "4", "dir" => "desc"}}, q: f.conditions.to_json}, :format => :json
        @parsed_body = JSON.parse(response.body)
      end

      it "show the list of filtered ParameterSets" do
        expect(@parsed_body["data"].size).to eq 5
        @parsed_body["data"].each do |ps|
          expect(ps[4].to_i).to be >= 5 #ps[4].to_i is qeual to v.L(ps[checkbox, progress, id, updated_at, [keys]])
        end
      end
    end
  end

  describe "GET _parameter_set_filters_list" do
    before(:each) do
      @simulator = FactoryBot.create(:simulator,
                                     parameter_set_filters_count: 5)
      get :_parameter_sets_list, params: {id: @simulator.to_param, draw: 1, start: 0, length:25}, format: :json
      @parsed_body = JSON.parse(response.body)
    end

    it "return json format" do
      expect(response.header['Content-Type']).to include 'application/json'
      expect(@parsed_body["recordsTotal"]).to eq 5
      expect(@parsed_body["recordsFiltered"]).to eq 5
    end
  end

  describe "GET _progress" do
    before(:each) do
      @simulator = FactoryBot.create(:simulator,
                                      parameter_sets_count: 30, runs_count: 3
                                      )
      get :_progress, params: {id: @simulator.to_param, column_parameter: 'L', row_parameter: 'T'}, :format => :json
      @parsed_body = JSON.parse(response.body)
    end

    it "return json format" do
      expect(response).to be_successful
      expect(response.header['Content-Type']).to include 'application/json'
      expect(@parsed_body["parameters"]).to eq ["L", "T"]
      expect(@parsed_body["parameter_values"]).to be_a(Array)
      expect(@parsed_body["num_runs"]).to be_a(Array)
    end
  end

  describe "POST _sort" do

    before(:each) do
      FactoryBot.create_list(:simulator, 3)
    end

    it "updates position of the simulators" do
      simulators = Simulator.asc(:position).to_a
      expect {
        post :_sort, params: {simulator: simulators.reverse }
        expect(response).to be_successful
      }.to change { simulators.first.reload.position }.from(0).to(2)
    end
  end

  describe "GET _host_parameters_field" do

    before(:each) do
      @host = FactoryBot.create(:host_with_parameters)
      @sim = FactoryBot.create(:simulator, parameter_sets_count: 0)
      @sim.executable_on.push(@host)
    end

    it "returns http success" do
      valid_param = {id: @sim.to_param, host_id: @host.to_param}
      get :_host_parameters_field, params: valid_param
      expect(response).to be_successful
    end

    it "returns http success even if host_id is not found" do
      param = {id: @sim.to_param, host_id: "DO_NOT_EXIST"}
      get :_host_parameters_field, params: param
      expect(response).to be_successful
    end
  end

  describe "GET _default_mpi_omp" do

    before(:each) do
      @host = FactoryBot.create(:host_with_parameters)
      @sim = FactoryBot.create(:simulator,
                                parameter_sets_count: 0, support_mpi: true, support_omp: true)
      @sim.executable_on.push(@host)
    end

    it "returns http success" do
      valid_param = {id: @sim.to_param, host_id: @host.to_param}
      get :_default_mpi_omp, params: valid_param
      expect(response).to be_successful
    end

    context "when default_mpi_procs and/or defualt_omp_threads are set" do

      before(:each) do
        @sim.update_attribute(:default_mpi_procs, {@host.id.to_s => 8})
        @sim.update_attribute(:default_omp_threads, {@host.id.to_s => 4})
      end

      it "returns mpi_procs and omp_threads in json" do
        valid_param = {id: @sim.to_param, host_id: @host.to_param}
        get :_default_mpi_omp, params: valid_param
        expect(response.header['Content-Type']).to include 'application/json'
        parsed = JSON.parse(response.body)
        expect(parsed).to eq ({'mpi_procs' => 8, 'omp_threads' => 4})
      end
    end

    context "when default_mpi_procs or default_omp_threads is not set" do

      before(:each) do
        @sim.update_attribute(:default_mpi_procs, {})
        @sim.update_attribute(:default_omp_threads, {})
      end

      it "returns mpi_procs and omp_threads in json" do
        valid_param = {id: @sim.to_param, host_id: @host.to_param}
        get :_default_mpi_omp, params: valid_param
        expect(response.header['Content-Type']).to include 'application/json'
        parsed = JSON.parse(response.body)
        expect(parsed).to eq ({'mpi_procs' => 1, 'omp_threads' => 1})
      end
    end
  end
end
