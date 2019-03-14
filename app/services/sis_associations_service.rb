class SisAssociationsService
  # Adds a SIS association to a person, including all associated concerns (e.g. group rules, inherited roles, sync actions)
  def self.add_sis_association_to_person(person, major, association_rank, level_code)
    raise 'Expected Person object' unless person.is_a?(Person)
    raise 'Expected Major object' unless major.is_a?(Major)
    raise 'Expected Integer object' unless association_rank.is_a?(Integer)
    raise 'Expected String object' unless level_code.is_a?(String)

    SisAssociation.create!(entity_id: person.id,
                           major: major,
                           association_rank: association_rank,
                           level_code: level_code)

    person.reload
    expired_group_ids, current_group_ids = GroupRulesService.update_results_for_columns([:sis_level_code, :major], person)

    # Unassign inherited roles from old groups
    expired_group_ids.each do |group_id|
      group = Group.find_by(id: group_id)
      RoleAssignmentsService.unassign_group_roles_from_member(group, person)
    end

    # Assign inherited roles to new groups
    current_group_ids.each do |group_id|
      group = Group.find_by(id: group_id)
      RoleAssignmentsService.assign_group_roles_to_member(group, person)
    end

    ActivityLog.info!("Added major #{major.name}", ["person_#{person.id}"])
  end

  # Removes a SIS association from a person, including all associated concerns (e.g. group rules, inherited roles, sync actions)
  def self.remove_sis_association_from_person(person, sis_association)
    raise 'Expected Person object' unless person.is_a?(Person)
    raise 'Expected SisAssociation object' unless sis_association.is_a?(SisAssociation)

    old_major_name = sis_association.major.name
    sis_association.destroy!

    person.reload
    expired_group_ids, current_group_ids = GroupRulesService.update_results_for_columns([:sis_level_code, :major], person)

    # Unassign inherited roles from old groups
    expired_group_ids.each do |group_id|
      group = Group.find_by(id: group_id)
      RoleAssignmentsService.unassign_group_roles_from_member(group, person)
    end

    # Assign inherited roles to new groups
    current_group_ids.each do |group_id|
      group = Group.find_by(id: group_id)
      RoleAssignmentsService.assign_group_roles_to_member(group, person)
    end

    ActivityLog.info!("Removed major #{old_major_name}", ["person_#{person.id}"])
  end

  def self.remove_all_sis_associations_from_person(person)
    raise 'Expected Person object' unless person.is_a?(Person)

    person.sis_associations.each do |assoc|
      self.remove_sis_association_from_person(person, assoc)
    end
  end
end
