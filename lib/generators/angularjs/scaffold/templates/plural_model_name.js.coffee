root = global ? window

angular.module("<%= @plural_model_name %>", ["ngResource"]).factory "<%= @model_name %>", ['$resource', ($resource) ->
  <%= "#{@model_name}" %> = $resource("/<%= @plural_model_name %>/:id<%
   if (filterColumns.length>0) %>?<%= filterColumns.first().name.to_s %>=:<%= filterColumns.first().name.to_s %><%
     filterColumns.drop(1).each{|fcolumn| %>&<%= fcolumn.name.to_s %>=:<%= fcolumn.name.to_s %><%}%><%
   end %>",
    id: "@id"<%
    if (filterColumns.length>0)
      filterColumns.each  do |fcolumn| %>,
    <%= fcolumn.name.to_s %>: "@<%= fcolumn.name.to_s %>"<%
       end
     end %>
  ,
    update:
      method: "PUT"

    destroy:
      method: "DELETE"
  )
  <%= "#{@model_name}" %>::destroy = (cb) ->
    <%= "#{@model_name}" %>.remove
      id: @id
    , cb

  <%= "#{@model_name}" %>
]
