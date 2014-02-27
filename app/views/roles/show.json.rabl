object @role
cache ['roles_show', @role]

child @role.role_assignments.select{ |a| a.entity.active == true } => :assignments do
  attributes :id, :entity_id
  glue(:entity) {
    attributes :type, :name
  }
  node :calculated do |a|
    a.parent_id != nil
  end
end