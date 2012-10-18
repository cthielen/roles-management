DssRm.Routers.Applications = Support.SwappingRouter.extend({
  initialize: function(options) {
    this.el = $('#applications');
    this.applications = options.applications;
    this.entities = options.entities;
  },

  routes: {
    "":                 "index",
    "new":              "newApplication",
    "applications/:id": "showApplication",
    "people/:id": "showPerson",
    "groups/:id": "showGroup"
  },

  index: function() {
    var view = new DssRm.Views.ApplicationsIndex({ applications: this.applications, entities: this.entities });
    this.swap(view);
  },

  newApplication: function() {
    //var view = new DssRm.Views.TasksNew({ collection: this.applications });
    //this.swap(view);
  },

  showApplication: function(applicationId) {
    var application = this.applications.get(applicationId);
    var applicationsRouter = this;
    application.fetch({
      success: function() {
        var view = new DssRm.Views.ApplicationShow({ model: application });
        applicationsRouter.currentView.renderChild(view);
        view.$el.modal();
      }
    });
  },

  showPerson: function(personId) {

  },

  showGroup: function(groupId) {
    var group = this.entities.get(groupId);
    var groupsRouter = this;
    group.fetch({
      success: function() {
        var view = new DssRm.Views.GroupShow({ model: group });
        groupsRouter.currentView.renderChild(view);
        view.$el.modal();
      }
    });
  }
});
