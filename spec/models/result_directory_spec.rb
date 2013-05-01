require 'spec_helper'

describe ResultDirectory do

  before(:each) do
    @simulator = FactoryGirl.create(:simulator,
                                    parameter_sets_count: 1,
                                    runs_count: 1
                                    )
    @default_root = ResultDirectory::DefaultResultRoot
  end

  after(:each) do
  end

  it ".root returns root dir" do
    ResultDirectory.root.should == @default_root
  end

  it ".set_root sets the result root directory" do
    another_root = Rails.root.join('testdir')
    ResultDirectory.set_root(another_root)
    ResultDirectory.root.should == another_root
    ResultDirectory.set_root(ResultDirectory::DefaultResultRoot)
  end
  
  it ".simulator_path returns the path to the simulator directory" do
    ResultDirectory.simulator_path(@simulator).should == @default_root.join(@simulator.to_param)
  end

  it ".simulator_path also accepts id object" do
    ResultDirectory.simulator_path(@simulator.to_param).should == ResultDirectory.simulator_path(@simulator)
  end

  it ".parameter_set_path returns the path to the parameter directory" do
    prm = @simulator.parameter_sets.first
    ResultDirectory.parameter_set_path(prm).should == @default_root.join(@simulator.to_param, prm.to_param)
  end

  it ".parameter_path also accepts id object" do
    prm = @simulator.parameter_sets.first
    ResultDirectory.parameter_set_path(prm.to_param).should == ResultDirectory.parameter_set_path(prm)
  end

  it ".run_path returns the run directory" do
    prm = @simulator.parameter_sets.first
    run = prm.runs.first
    ResultDirectory.run_path(run).should ==
      @default_root.join(@simulator.to_param, prm.to_param, run.to_param)
  end

  it ".run_path also accepts id object" do
    prm = @simulator.parameter_sets.first
    run = prm.runs.first
    ResultDirectory.run_path(run.to_param).should == ResultDirectory.run_path(run)
  end

  it ".run_script_path returns the path to the run script" do
    prm = @simulator.parameter_sets.first
    run = prm.runs.first
    ResultDirectory.run_script_path(run).should ==
      @default_root.join(@simulator.to_param, prm.to_param, run.to_param + '.sh')
  end
end