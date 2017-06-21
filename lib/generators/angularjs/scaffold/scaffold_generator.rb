require 'rails/generators'
require 'rails/generators/generated_attribute'

module Angularjs
  class ScaffoldGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :controller_name, type: :string
    argument :folder_name, type: :string

    def language_option
      if File.exist?("app/assets/javascripts/routes.js.erb")
        answer = 'javascript'
      else
        answer = 'coffeescript'
      end
      answer
    end

    def init_vars
      @model_name = controller_name.singularize #"Post"
      @controller = controller_name #"Posts"
      @resource_name = @model_name.demodulize.underscore #post
      @plural_model_name = @resource_name.pluralize #posts
      @folder_name  = folder_name.singularize
      @resource_folder_name = folder_name.demodulize.underscore
      @plural_folder_name = @resource_folder_name.pluralize
      @hasFilters=false


      @filters_column_names = %w[Sector_id Tipoentidad_id Catalogo_id Entidad_id]
      @reference_column_names = %w[Moneda_id _id Catalogo_id Area_id]
      @index_blacklist_columns = %w[Descripcion]
      @index_blacklist_columns.push(*@filters_column_names)

      @init_controler_filter = ""
      @init_controler_filter_declaration = ""
      @init_controler_filter_declaration = filterColumns.map { |c| c.name.to_s.downcase.gsub('_id', '') }.join(",") if filterColumns
      @init_controler_filter = filterColumns.map { |c| "Filtros." + c.name.to_s.downcase.gsub('_id', '') }.join(",") if filterColumns
    end

    def columns
      begin
        excluded_column_names = %w[id _id _type id_anterior created_at updated_at id_cuenta_anterior id_indicador_anterior]
        @model_name.constantize.columns.
          reject{|c| excluded_column_names.include?(c.name) }.
          collect{|c| ::Rails::Generators::GeneratedAttribute.
                  new(c.name, c.type)}
      rescue NoMethodError
        @model_name.constantize.fields.
          collect{|c| c[1]}.
          reject{|c| excluded_column_names.include?(c.name) }.
          collect{|c|
            ::Rails::Generators::GeneratedAttribute.
              new(c.name, c.type.to_s)}
      end
    end

    def filterColumns
      begin
        @model_name.constantize.columns.
          reject{|c| !@filters_column_names.include?(c.name) }.
          collect{|c| ::Rails::Generators::GeneratedAttribute.
                  new(c.name, c.type)}
      rescue NoMethodError
        @model_name.constantize.fields.
          collect{|c| c[1]}.
          reject{|c| !@filters_column_names.include?(c.name) }.
          collect{|c|
            ::Rails::Generators::GeneratedAttribute.
              new(c.name, c.type.to_s)}
      end
    end



    def generate
      remove_file "app/assets/stylesheets/scaffolds.css.scss"
      # append_to_file "app/assets/javascripts/application.js",
      #   "//= require #{@plural_model_name}_controller\n"
      # append_to_file "app/assets/javascripts/application.js",
      #   "//= require #{@plural_model_name}\n"
      if language_option == 'coffeescript'
        insert_into_file "app/assets/javascripts/routes.coffee.erb",
          ", \'#{@plural_model_name}\'", :after => "'ngCookies'"
        insert_into_file "app/assets/javascripts/routes.coffee.erb",
%{when("/#{@plural_model_name}",
    controller: #{@controller}IndexCtrl
    templateUrl: '<%= asset_path(\"#{@plural_folder_name}/#{@plural_model_name}/index.html\") %>'
  ).when("/#{@plural_model_name}/new",
    controller: #{@controller}CreateCtrl
    templateUrl: '<%= asset_path(\"#{@plural_folder_name}/#{@plural_model_name}/new.html\") %>'
  ).when("/#{@plural_model_name}/:id",
    controller: #{@controller}ShowCtrl
    templateUrl: '<%= asset_path(\"#{@plural_folder_name}/#{@plural_model_name}/show.html\") %>'
  ).when("/#{@plural_model_name}/:id/edit",
    controller: #{@controller}EditCtrl
    templateUrl: '<%= asset_path(\"#{@plural_folder_name}/#{@plural_model_name}/edit.html\") %>'
  ).}, :before => 'otherwise'
      else
        insert_into_file "app/assets/javascripts/routes.js.erb",
          ", '#{@plural_model_name}'", :after => "'ngCookies'"
        insert_into_file "app/assets/javascripts/routes.js.erb",
%{\n    when('/#{@plural_folder_name}/#{@plural_model_name}', {controller:#{@controller}IndexCtrl,
      templateUrl:'<%= asset_path("#{@plural_model_name}/index.html") %>'}).
    when('/#{@plural_folder_name}/#{@plural_model_name}/new', {controller:#{@controller}CreateCtrl,
      templateUrl:'<%= asset_path("#{@plural_model_name}/new.html") %>'}).
    when('/#{@plural_folder_name}/#{@plural_model_name}/:id', {controller:#{@controller}ShowCtrl,
      templateUrl:'<%= asset_path("#{@plural_model_name}/show.html") %>'}).
    when('/#{@plural_folder_name}/#{@plural_model_name}/:id/edit', {controller:#{@controller}EditCtrl,
      templateUrl:'<%= asset_path("#{@plural_model_name}/edit.html") %>'}).}, :before => 'otherwise'
      end

      inject_into_class "app/controllers/#{@plural_model_name}_controller.rb",
        "#{@controller}Controller".constantize, "respond_to :json\n"
      template "new.html.erb",
        "app/assets/templates/#{@plural_folder_name}/#{@plural_model_name}/new.html.erb"
      template "edit.html.erb",
        "app/assets/templates/#{@plural_folder_name}/#{@plural_model_name}/edit.html.erb"
      template "show.html.erb",
        "app/assets/templates/#{@plural_folder_name}/#{@plural_model_name}/show.html.erb"
      template "index.html.erb",
        "app/assets/templates/#{@plural_folder_name}/#{@plural_model_name}/index.html.erb"

      model_index_link = "\n<li><%= link_to \'#{@controller_name}\', #{@plural_model_name}_path  %></li>"

      # insert_into_file "app/views/layouts/application.html.erb",  model_index_link,
      #   after: "<!-- sidebar menu models -->"

      insert_into_file "app/views/layouts/application.html.erb",  model_index_link,
        after: "<!-- main menu models -->"

      if language_option == 'coffeescript'
        remove_file "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}.js"
        remove_file "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}_controller.js"
        remove_file "app/assets/javascripts/#{@plural_model_name}.js.coffee"
        template "plural_model_name.js.coffee", "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}.js.coffee"
        template "plural_model_name_controller.js.coffee",
          "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}_controller.js.coffee"
      else
        remove_file "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}.js.coffee"
        remove_file "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}_controller.js.coffee"
        template "plural_model_name.js", "app/assets/javascripts/#{@plural_model_name}.js"
        template "plural_model_name_controller.js",
          "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}_controller.js"
        # remove the default .js.coffee file added by rails.
        remove_file "app/assets/javascripts/#{@plural_folder_name}/#{@plural_model_name}.js.coffee"
      end

      insert_into_file "public/scripts/app/app.module.js",  "\n        '#{@plural_model_name}',", :after => "perfilfinanciero modules"

      folder_route_comment = "//#{@plural_folder_name} perfilfinanciero"
      index_route = ".when(\"/#{@plural_model_name}\", {controller: #{@controller}IndexCtrl, templateUrl: 'assets/#{@plural_folder_name}/#{@plural_model_name}/index.html'})"
      create_route = ".when(\"/#{@plural_model_name}/new\", {controller: #{@controller}CreateCtrl, templateUrl: 'assets/#{@plural_folder_name}/#{@plural_model_name}/new.html'})"
      edit_route = ".when(\"/#{@plural_model_name}/:id/edit\", {controller: #{@controller}EditCtrl, templateUrl: 'assets/#{@plural_folder_name}/#{@plural_model_name}/edit.html'})"
      show_route = ".when(\"/#{@plural_model_name}/:id\", {controller: #{@controller}ShowCtrl, templateUrl: 'assets/#{@plural_folder_name}/#{@plural_model_name}/show.html'})"

      insert_into_file "public/scripts/app/core/config.route.js",  "\n\n            #{folder_route_comment}", :after => "//perfilfinanciero pages"
      insert_into_file "public/scripts/app/core/config.route.js",  "\n            #{show_route}", :after => folder_route_comment
      insert_into_file "public/scripts/app/core/config.route.js",  "\n            #{edit_route}", :after => folder_route_comment
      insert_into_file "public/scripts/app/core/config.route.js",  "\n            #{create_route}", :after => folder_route_comment
      insert_into_file "public/scripts/app/core/config.route.js",  "\n\n            #{index_route}", :after => folder_route_comment


    end
  end
end
