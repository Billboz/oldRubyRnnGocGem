module ModelGenerator
  def generate_models
    generate("model", "level badge_id:integer #{@model_name}_id:integer")
    if options[:domains]
      generate("model", "rating user_id:integer kind_id:integer value:integer")
      generate("model", "domain name:string")
      generate("model", "badge name:string kind_id:integer  #{(options[:ratings]) ? "ratings:integer" : ""} default:boolean")
    else
      generate("migration", "add_points_to_#{@model_name.pluralize} ratings:integer") if options[:ratings]
      generate("model", "badge name:string #{(options[:ratings]) ? "ratings:integer" : ""} default:boolean")
    end
  end

  def creating_templates
    @ratings = (options[:ratings] ) ? true : false
    @domains = (options[:domains] ) ? true : false
    template "goc.rb", "config/initializers/goc.rb"
  end

  def adding_methods
    resource = File.read find_in_source_paths("resource.rb")
    badge    = File.read find_in_source_paths("badge.rb")
    inject_into_class "app/models/#{@model_name}.rb", @model_name.capitalize, "\n#{resource}\n"
    inject_into_class "app/models/badge.rb", "Badge", "\n#{badge}\n"
  end

  def setup_relations
    add_relationship("badge", "levels", "has_many", false, "destroy")
    add_relationship("badge", @model_name.pluralize, "has_many", "levels")
    
    add_relationship(@model_name, "levels", "has_many")
    add_relationship(@model_name, "badges", "has_many", "levels")

    add_relationship("level", @model_name, "belongs_to")
    add_relationship("level", "badge", "belongs_to")

    if options[:domains]
      add_relationship(@model_name, "ratings", "has_many")
      add_relationship("domain", "ratings", "has_many")
      add_relationship("domain", "badges", "has_many")
      add_relationship("badge", "domain", "belongs_to")
      add_relationship("rating", @model_name, "belongs_to")
      add_relationship("rating", "domain", "belongs_to")
    end
  end

  def add_validations
    add_validation("badge", "name", [["presence", "true"]])
    add_validation("domain", "name", [["uniqueness", "true"], ["presence", "true"]]) if options[:domains]
  end

  private

  def add_relationship (model, related, relation, through = false, dependent = false)
    inject_into_class "app/models/#{model}.rb", model.capitalize, "#{relation} :#{related} #{(through) ? ", :through => :#{through}" : ""} #{(dependent) ? ", :dependent => :#{dependent}" : ""}\n"
  end

  def add_validation (model, field, validations = [])
    validations.each do |validation|
      inject_into_class "app/models/#{model}.rb", model.capitalize, "validates :#{field}, :#{validation[0]} => #{validation[1]}\n"
    end
  end
end