class Role < ActiveRecord::Base
  has_many :role_assignments
  has_many :people, :through => :role_assignments
  has_many :groups, :through => :role_assignments
  
  belongs_to :application
  
  attr_accessible :token, :people_tokens, :people_ids, :default, :group_tokens, :descriptor, :description
  attr_reader :people_tokens, :group_tokens
  
  def people_tokens=(ids)
      self.person_ids = ids.split(",").collect { |x| x[1..-1] } # cut off the UID (see README)
  end
  def group_tokens=(ids)
      self.group_ids = ids.split(",").collect { |x| x[1..-1] } # cut off the UID (see README)
  end
  
  def as_json(options={}) 
      { :id => self.id, :token => self.token, :descriptor => self.descriptor, :application_id => self.application_id, :description => self.description } 
  end
end
