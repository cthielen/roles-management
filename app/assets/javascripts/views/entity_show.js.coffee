DssRm.Views.EntityShow = Support.CompositeView.extend(
  tagName: "div"
  className: "modal"
  id: "entityShowModal"
  events:
    "click a#apply": "save"
    "click a#rescan": "rescan"
    "click button#group_rule_add": "addRule"
    "click button#remove_group_rule": "removeRule"
    "change table#rules select": "storeRuleChanges"
    "change table#rules input": "storeRuleChanges"
    "hidden": "cleanUpModal"
    "click #delete": "deleteEntity"

  initialize: ->
    self = this
    type = @model.get("type")
    @model.on "change", @render, this
    @$el.html JST["entities/show_" + @model.get("type").toLowerCase()](model: @model)
    if type is "Group"
      @$("input[name=owners]").tokenInput Routes.people_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          owners = self.model.get("owners")
          unless _.find(owners, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            owners.push item
            self.model.set "owners", owners

        onDelete: (item) ->
          owners = _.filter(self.model.get("owners"), (owner) ->
            owner.id isnt item.id
          )
          self.model.set "owners", owners

      @$("input[name=operators]").tokenInput Routes.people_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          operators = self.model.get("operators")
          unless _.find(operators, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            operators.push item
            self.model.set "operators", operators

        onDelete: (item) ->
          operators = _.filter(self.model.get("operators"), (operator) ->
            operator.id isnt item.id
          )
          self.model.set "operators", operators

      @$("input[name=members]").tokenInput Routes.people_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          members = self.model.get("members")
          unless _.find(members, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            members.push item
            self.model.set "members", members

        onDelete: (item) ->
          members = _.filter(self.model.get("members"), (member) ->
            member.id isnt item.id
          )
          self.model.set "members", members

    else if type is "Person"
      @$("input[name=favorites]").tokenInput Routes.people_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          favorites = self.model.get("favorites")
          unless _.find(favorites, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            favorites.push item
            self.model.set "favorites", favorites

        onDelete: (item) ->
          favorites = _.filter(self.model.get("favorites"), (favorite) ->
            favorite.id isnt item.id
          )
          self.model.set "favorites", favorites

      @$("input[name=groups]").tokenInput Routes.groups_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          group_memberships = self.model.get("group_memberships")
          unless _.find(group_memberships, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            group_memberships.push item
            self.model.set "group_memberships", group_memberships

        onDelete: (item) ->
          group_memberships = _.filter(self.model.get("group_memberships"), (group) ->
            group.id isnt item.id
          )
          self.model.set "group_memberships", group_memberships

      @$("input[name=ous]").tokenInput Routes.ous_path(),
        crossDomain: false
        defaultText: ""
        theme: "facebook"
        onAdd: (item) ->
          ous = self.model.get("ous")
          unless _.find(ous, (i) ->
            i.id is item.id
          )
            
            # onAdd is triggered by the .tokenInput("add") lines in render,
            # so we need to ensure this actually is a new item
            ous.push item
            self.model.set "ous", ous

        onDelete: (item) ->
          ous = _.filter(self.model.get("ous"), (ou) ->
            ou.id isnt item.id
          )
          self.model.set "ous", ous

      $rolesTab = @$("fieldset#roles")
      _.each @model.roles.groupBy("application_name"), (roleset) ->
        app_name = roleset[0].get("application_name")
        app_id = roleset[0].get("application_id")
        $rolesTab.append "           <p>             <label for=\"_token_input_" + app_id + "\">" + app_name + "</label>             <input type=\"text\" name=\"_token_input_" + app_id + "\" class=\"token_input\" />           </p>"
        $rolesTab.find("input[name=_token_input_" + app_id + "]").tokenInput Routes.roles_path() + "?application_id=" + app_id,
          crossDomain: false
          defaultText: ""
          theme: "facebook"
          onAdd: (item) ->
            roles = self.model.get("roles")
            unless _.find(roles, (i) ->
              i.id is item.id
            )
              
              # onAdd is triggered by the .tokenInput("add") lines in render,
              # so we need to ensure this actually is a new item
              roles.push item
              self.model.set "roles", roles
              self.model.trigger "change"

          onDelete: (item) ->
            roles = _.filter(self.model.get("roles"), (role) ->
              role.id isnt item.id
            )
            self.model.set "roles", roles
            self.model.trigger "change"



  render: ->
    self = this
    type = @model.get("type")
    if type is "Group"
      
      # Summary tab
      self.$("h3").html @model.escape("name")
      self.$("input[name=name]").val @model.get("name")
      self.$("textarea[name=description]").val @model.escape("description")
      self.$("span#group_member_count").html @model.get("members").length
      owners_tokeninput = self.$("input[name=owners]")
      owners_tokeninput.tokenInput "clear"
      _.each @model.get("owners"), (owner) ->
        owners_tokeninput.tokenInput "add",
          id: owner.id
          name: owner.name


      operators_tokeninput = self.$("input[name=operators]")
      operators_tokeninput.tokenInput "clear"
      _.each @model.get("operators"), (operator) ->
        operators_tokeninput.tokenInput "add",
          id: operator.id
          name: operator.name


      members_tokeninput = self.$("input[name=members]")
      members_tokeninput.tokenInput "clear"
      _.each @model.get("members"), (member) ->
        members_tokeninput.tokenInput "add",
          id: member.id
          name: member.name


      @$("span#csv-download>a").attr "href", Routes.entity_path(@model.id) + ".csv"
      
      # Rules tab
      rules_table = self.$("table#rules tbody")
      rules_table.empty()
      _.each @model.get("rules"), (rule, i) ->
        $rule = $(JST["entities/group_rule"]())
        $rule.find("td:nth-child(1) select").val rule.column
        $rule.find("td:nth-child(2) select").val rule.condition
        $rule.find("td:nth-child(3) input").val rule.value
        $rule.data "rule_id", rule.id
        rules_table.append $rule

      if @model.get("rules").length is 0
        self.$("table#rules tbody").hide()
      else
        self.$("table#rules tbody").show()
      self.$("table#rules tbody tr").each (i, e) ->
        $(e).find("input#value").typeahead
          minLength: 2
          sorter: (items) -> # required to keep the order given to process() in 'source'
            items

          highlighter: (item) ->
            item = item.split("####")[1] # See: https://gist.github.com/3694758 (FIXME when typeahead supports passing objects)
            query = @query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, "\\$&")
            item.replace new RegExp("(" + query + ")", "ig"), ($1, match) ->
              "<strong>" + match + "</strong>"


          source: self.ruleSearch
          updater: (item) ->
            self.ruleSearchResultSelected item, self


    else if type is "Person"
      
      # Summary tab
      self.$("h3").html @model.escape("name")
      self.$("h5").html @model.escape("byline")
      self.$("input[name=first]").val @model.escape("first")
      self.$("input[name=last]").val @model.escape("last")
      self.$("input[name=email]").val @model.escape("email")
      self.$("input[name=loginid]").val @model.escape("loginid")
      self.$("input[name=phone]").val @model.escape("phone")
      self.$("input[name=address]").val @model.get("address")
      favorites_tokeninput = self.$("input[name=favorites]")
      favorites_tokeninput.tokenInput "clear"
      _.each @model.get("favorites"), (favorite) ->
        favorites_tokeninput.tokenInput "add",
          id: favorite.id
          name: favorite.name


      groups_tokeninput = self.$("input[name=groups]")
      groups_tokeninput.tokenInput "clear"
      _.each @model.get("group_memberships"), (group) ->
        groups_tokeninput.tokenInput "add",
          id: group.id
          name: group.name


      ous_tokeninput = self.$("input[name=ous]")
      ous_tokeninput.tokenInput "clear"
      _.each @model.get("ous"), (ou) ->
        ous_tokeninput.tokenInput "add",
          id: ou.id
          name: ou.name


      
      # Roles tab
      $rolesTab = @$("fieldset#roles")
      _.each @model.roles.groupBy("application_name"), (roleset) ->
        app_name = roleset[0].get("application_name")
        app_id = roleset[0].get("application_id")
        role_tokeninput = self.$("input[name=_token_input_" + app_id + "]")
        role_tokeninput.tokenInput "clear"
        _.each roleset, (role) ->
          role_tokeninput.tokenInput "add",
            id: role.get("id")
            name: role.get("name")



    this

  save: (e) ->
    type = @model.get("type")
    status_bar.show "Saving ..."
    if type is "Group"
      @model.set
        name: @$("input[name=name]").val()
        description: @$("textarea[name=description]").val()

    else if type is "Person"
      @model.set
        first: @$("input[name=first]").val()
        last: @$("input[name=last]").val()
        email: @$("input[name=email]").val()
        loginid: @$("input[name=loginid]").val()
        phone: @$("input[name=phone]").val()
        address: @$("input[name=address]").val()

    @model.save {},
      success: ->
        status_bar.hide()

      error: ->
        status_bar.show "An error occurred while saving.", "error"

    console.log "saving entity with cid:" + @model.cid
    @model.trigger "change"
    false

  rescan: (e) ->
    type = @model.get("type")
    status_bar.show "Scanning ..."
    
    #this.model.save({}, {
    #success: function() {
    status_bar.hide()
    
    #},
    
    #error: function() {
    #status_bar.show("An error occurred while saving.", "error");
    #}
    #});
    false

  deleteEntity: ->
    self = this
    
    self.$el.fadeOut()
    
    bootbox.confirm "Are you sure you want to delete " + @model.escape("name") + "?", (result) ->
      self.$el.fadeIn()
      if result
        # delete the application and dismiss the dialog
        self.model.destroy()
        
        # dismiss the dialog
        self.$(".modal-header a.close").trigger "click"

    false

  addRule: (e) ->
    updated_rules = _.clone(@model.get("rules"))
    
    # the false ID simply needs to be unique in case the 'remove' button is hit - our backend will provide a proper ID on saving
    updated_rules.push
      column: "ou"
      condition: "is"
      value: ""
      id: "new_" + Math.round((new Date()).getTime())

    @model.set rules: updated_rules

  removeRule: (e) ->
    rule_id = $(e.target).parents("tr").data("rule_id")
    @model.set rules: _.reject(@model.get("rules"), (r) ->
      r.id is rule_id
    )

  
  # Copies values off the DOM into this.model
  storeRuleChanges: (e) ->
    rule_id = $(e.target).parents("tr").data("rule_id")
    column = $(e.target).parents("tr").children("td:nth-child(1)").find("select").val()
    condition = $(e.target).parents("tr").children("td:nth-child(2)").find("select").val()
    value = $(e.target).parents("tr").children("td:nth-child(3)").find("input").val()
    @model.set rules: _.map(@model.get("rules"), (r) ->
      if r.id is rule_id
        r.column = column
        r.condition = condition
        r.value = value
      r
    )

  cleanUpModal: ->
    @model.off "change", @render, this
    $("div#entityShowModal").remove()
    
    # Need to change URL in case they want to open the same modal again
    Backbone.history.navigate ""

  
  # Populates the sidebar search with results via async call
  ruleSearch: (query, process, e) ->
    lookahead_type = @$element.parents("tr").find("td:first select").val()
    lookahead_url = ""
    switch lookahead_type
      when "major"
        lookahead_url = Routes.majors_path()
      when "ou"
        lookahead_url = Routes.ous_path()
      when "loginid"
        lookahead_url = Routes.people_path()
      when "title"
        lookahead_url = Routes.titles_path()
      when "affiliation"
        lookahead_url = Routes.affiliations_path()
      when "classification"
        lookahead_url = Routes.classifications_path()
    $.ajax(
      url: lookahead_url
      data:
        q: query

      type: "GET"
    ).always (data) ->
      entities = []
      _.each data, (entity) ->
        if lookahead_type is "loginid"
          entities.push entity.id + "####" + entity.loginid
        else
          entities.push entity.id + "####" + entity.name

      process entities


  ruleSearchResultSelected: (item, self) ->
    parts = item.split("####")
    id = parseInt(parts[0])
    label = parts[1]
    label
)