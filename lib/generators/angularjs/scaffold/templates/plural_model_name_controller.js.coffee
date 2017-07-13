
root = global ? window

<%= @controller %>IndexCtrl = ($scope,$filter,<%= @init_controler_filter?" Filtros, ":"" %> <%= @model_name %>) ->
  $scope.searchKeywords = ''
  $scope.filtered<%= @controller %> = []
  $scope.row = ''

  $scope.select = (page) ->
      end = undefined
      start = undefined
      start = (page - 1) * $scope.numPerPage
      end = start + $scope.numPerPage
      return $scope.currentPage<%= @controller %> = $scope.filtered<%= @controller %>.slice(start, end)


  $scope.destroy = ->
    if confirm("Are you sure?")
      original = @<%= @resource_name %>
      @<%= @resource_name %>.destroy ->
        $scope.<%= @plural_model_name %> = _.without($scope.<%= @plural_model_name %>, original)

  $scope.onFilterChange = ->
    $scope.select 1
    $scope.currentPage = 1
    $scope.row = ''

  $scope.onNumPerPageChange = ->
    $scope.select 1
    $scope.currentPage = 1

  $scope.onOrderChange = ->
    $scope.select 1
    $scope.currentPage = 1

  $scope.search = ->
    $scope.filtered<%= @controller %> = $filter('filter')($scope.<%= @plural_model_name %>, $scope.searchKeywords)
    $scope.onFilterChange()

  $scope.order = (rowName) ->
    if $scope.row == rowName
      return
    $scope.row = rowName
    $scope.filtered<%= @controller %> = $filter('orderBy')($scope.<%= @plural_model_name %>, rowName)
    $scope.onOrderChange()

  $scope.numPerPageOpt = [
    3
    5
    10
    20
  ]
  $scope.numPerPage = $scope.numPerPageOpt[2]
  $scope.currentPage = 1
  $scope.currentPage<%= @controller %> = []

  $scope.init = () -><%
  if (filterColumns.length>0) %>
    if <%= get_column_filter_path(filterColumns.first().name.to_s) %> == undefined or <%= get_column_filter_path(filterColumns.first().name.to_s) %> == null
      $scope.<%= @plural_model_name %> = []
      $scope.filtered<%= @plural_model_name %> = []
      $scope.search()<% filterColumns.drop(1).each do |fcolumn| %>
    else if <%= get_column_filter_path(fcolumn.name.to_s) %> == undefined or <%= get_column_filter_path(fcolumn.name.to_s) %> == null
      $scope.<%= @plural_model_name %> = []
      $scope.filtered<%= @plural_model_name %> = []
      $scope.search()<% end %>
    else
      <%= @model_name %>.query
        <%= filterColumns.first().name.to_s%>: <%= get_column_filter_path(filterColumns.first().name.to_s) %>.id<% filterColumns.drop(1).each do |fcolumn| %>
        <%= fcolumn.name.to_s%>: <%= get_column_filter_path(fcolumn.name.to_s) %>.id<% end %>
      , (<%= @plural_model_name %>) ->
        $scope.<%= @plural_model_name %> = <%= @plural_model_name %>
        $scope.search()
  <% else %>
    <%= @model_name %>.query(
      (<%= @plural_model_name %>) ->
        $scope.<%= @plural_model_name %> = <%= @plural_model_name %>
        $scope.search()
    )
  <% end %>
  $scope.init()

<%= @controller %>IndexCtrl.$inject = ['$scope','$filter',<%= @init_controler_filter?" 'Filtros', ":"" %> '<%= @model_name %>'];

<%= @controller %>CreateCtrl = ($scope, $location, <%= @model_name %><%= get_references_list_parameters() %>) ->
  $scope.save = ->
    <%= @model_name %>.save $scope.<%= @resource_name %>, (<%= @resource_name %>) ->
      $location.path "/<%= @plural_model_name %>/#{<%= @resource_name %>.id}/edit"
<% if (referencedColumns.length>0)
     for column in referencedColumns %>
  $scope.load<%= column.name.to_s.gsub('_id', '') %> = () ->
    <%= column.name.to_s.gsub('_id', '') %>.query(
      (<%= get_list_name(column.name) %>) ->
        $scope.<%= get_list_name(column.name) %> = <%= get_list_name(column.name) %>
    )<%
    end
  end
  if (referencedColumns.length>0)
     for column in referencedColumns %>
  $scope.load<%= column.name.to_s.gsub('_id', '') %>()<% end
  end %>

<%= @controller %>CreateCtrl.$inject = ['$scope', '$location', '<%= @model_name %>'<%= get_references_list_injections() %>];

<%= @controller %>ShowCtrl = ($scope, $location, $routeParams, <%= @model_name %>) ->
  <%= @model_name %>.get
    id: $routeParams.id
  , (<%= @resource_name %>) ->
    @original = <%= @resource_name %>
    $scope.<%= @resource_name %> = new <%= @model_name %>(@original)

  $scope.destroy = ->
    if confirm("Are you sure?")
      $scope.<%= @resource_name %>.destroy ->
        $location.path "/<%= @plural_model_name %>"

<%= @controller %>ShowCtrl.$inject = ['$scope', '$location', '$routeParams', '<%= @model_name %>'];

<%= @controller %>EditCtrl = ($scope, $location, $routeParams, <%= @model_name %><%= get_references_list_parameters() %>) ->
  <%= @model_name %>.get
    id: $routeParams.id
  , (<%= @resource_name %>) ->
    @original = <%= @resource_name %>
    $scope.<%= @resource_name %> = new <%= @model_name %>(@original)

  $scope.isClean = ->
    console.log "[<%= @controller %>EditCtrl, $scope.isClean]"
    angular.equals @original, $scope.<%= @resource_name %>

  $scope.destroy = ->
    if confirm("Are you sure?")
      $scope.<%= @resource_name %>.destroy ->
        $location.path "/<%= @plural_model_name %>"

  $scope.save = ->
    <%= @model_name %>.update $scope.<%= @resource_name %>, (<%= @resource_name %>) ->
      $location.path "/<%= @plural_model_name %>"
<% if (referencedColumns.length>0)
     for column in referencedColumns %>
  $scope.load<%= column.name.to_s.gsub('_id', '') %> = () ->
    <%= column.name.to_s.gsub('_id', '') %>.query(
      (<%= get_list_name(column.name) %>) ->
        $scope.<%= get_list_name(column.name) %> = <%= get_list_name(column.name) %>
    )<%
    end
  end
  if (referencedColumns.length>0)
     for column in referencedColumns %>
  $scope.load<%= column.name.to_s.gsub('_id', '') %>()<% end
  end %>

<%= @controller %>EditCtrl.$inject = ['$scope', '$location', '$routeParams', '<%= @model_name %>'<%= get_references_list_injections() %>];

# exports
root.<%= @controller %>IndexCtrl  = <%= @controller %>IndexCtrl
root.<%= @controller %>CreateCtrl = <%= @controller %>CreateCtrl
root.<%= @controller %>ShowCtrl   = <%= @controller %>ShowCtrl
root.<%= @controller %>EditCtrl   = <%= @controller %>EditCtrl
