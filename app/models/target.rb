class Target < ActiveRecord::Base
  attr_accessible :name, :lat_tt, :loft_tt, :is_valid

  def as_json(_options = {})
    {
      name: name,
      lat_tt: lat_tt,
      loft_tt: loft_tt
    }
  end

  def self.get_targets
    # Definitely a race condition in here.
    targets = Target.where(is_valid: true).to_a
    targets.each do |t|
      t.update_attributes!(is_valid: false)
    end
    targets
  end
end
