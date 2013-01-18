DssRm.Models.Application = Backbone.Model.extend({
  initialize: function() {
    // Be sure to use this.roles and this.owners and not this.get('roles'), etc.
    this.roles = new DssRm.Collections.Roles(this.get('roles'));
    this.owners = new DssRm.Collections.Entities(this.get('owners'));
    this.operators = new DssRm.Collections.Entities(this.get('operators'));

    this.on("sync", this.updateAttributes, this);
    this.on("change", this.updateAttributes, this);
  },

  updateAttributes: function() {
    this.roles.reset(this.get('roles'), { silent: true });
    this.owners.reset(this.get('owners'), { silent: true });
    this.operators.reset(this.get('operators'), { silent: true });
  },

  // Returns only the "highest" relationship (this order): admin, owner, operator
  // Uses DssRm.current_user as the entity
  relationship: function() {
    var current_user_id = DssRm.current_user.get('id')

    if(DssRm.current_user.get('admin')) return "admin";

    if(this.owners.find(function(o) { return o.id == current_user_id; } ) !== undefined) return "owner";
    if(this.operators.find(function(o) { return o.id == current_user_id; } ) !== undefined) return "operator";

    return null;
  },

  toJSON: function() {
    var json = _.omit(this.attributes, 'roles', 'owners', 'uids', 'operators');

    json.roles_attributes = this.roles.map(function(role) {
      var r = {};

      if(role.id) r.id = role.id.toString();
      if(role.entities.length > 0) r.entity_ids = role.entities.map(function(e) { return e.id });
      r.token = role.get('token');
      r.default = role.get('default');
      r.name = role.get('name');
      r.description = role.get('description');

      return r;
    });
    json.owner_ids = this.owners.map(function(owner) {
      return owner.id;
    });
    json.operator_ids = this.operators.map(function(operator) {
      return operator.id;
    });

    return json;
  }
});
