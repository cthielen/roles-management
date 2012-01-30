module ApplicationHelper
  def current_controller?(options)
      options[:controller] == controller_name
  end
  
  def current_action?(options)
      options[:action] == action_name
  end
  
  def current_user
    Person.find_by_loginid(session[:cas_user])
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => "edit_mode")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, '#{association}', '#{escape_javascript(fields)}')", :class => "edit_mode")
  end
end
