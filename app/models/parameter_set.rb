class ParameterSet
  include Mongoid::Document
  include Mongoid::Timestamps
  field :v, type: Hash
  belongs_to :simulator
  has_many :runs, dependent: :destroy
  has_many :analyses, as: :analyzable, dependent: :destroy

  validates :simulator, :presence => true
  validate :cast_and_validate_parameter_values

  after_create :create_parameter_set_dir
  before_destroy :delete_parameter_set_dir

  attr_accessible :v

  public
  def dir
    ResultDirectory.parameter_set_path(self)
  end

  def parameter_sets_with_different(key)
    query_param = { simulator: self.simulator }
    v.each_pair do |prm_key,prm_val|
      next if prm_key == key.to_s
      query_param["v.#{prm_key}"] = prm_val
    end
    self.class.where(query_param).asc("v.#{key}")
  end

  def similar_parameter_sets
    h = {}
    simulator.parameter_definitions.map(&:key).each do |key|
      h[key] = parameter_sets_with_different(key)
    end
    h
  end

  def neighbor_parameter_sets
    h = {}
    simulator.parameter_definitions.map(&:key).each do |key|
      similar = parameter_sets_with_different(key)
      idx = similar.distinct("v.#{key}").index(v[key])
      neighbors = Array.new(2)
      neighbors[0] = similar[idx-1] if idx > 0
      neighbors[1] = similar[idx+1] if idx + 1 < similar.count
      h[key] = neighbors
    end
    h
  end

  def runs_status_count
    counts = {}
    counts[:total] = runs.count
    counts[:finished] = runs.where(status: :finished).count
    counts[:running] = runs.where(status: :running).count
    counts[:failed] = runs.where(status: :failed).count
    counts
  end

  private
  def cast_and_validate_parameter_values
    unless v.is_a?(Hash)
      errors.add(:v, "v is not a Hash")
      return
    end

    return unless self.simulator # presence of simulator is checked by another validator

    # cast parameter values
    defn = self.simulator.parameter_definitions
    casted = ParametersUtil.cast_parameter_values(v, defn, errors)
    if errors.any?
      return
    end
    self.v = casted

    found = self.class.find_identical_parameter_set(simulator, v)
    if found and found.id != self.id
      errors.add(:parameters, "An identical parameters already exists : #{found.to_param}")
      return
    end
  end

  def self.find_identical_parameter_set(simulator, sim_param_hash)
    self.where(:simulator => simulator, :v => sim_param_hash).first
  end

  def create_parameter_set_dir
    FileUtils.mkdir_p(ResultDirectory.parameter_set_path(self))
  end

  def delete_parameter_set_dir
    # if self.simulator.nil, parent Simulator is already destroyed.
    # Therefore, self.dir raises an exception
    if self.simulator and File.directory?(self.dir)
      FileUtils.rm_r(self.dir)
    end
  end
end
