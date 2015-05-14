require "generators/goc/model_generator"
require "generators/goc/rakes_generator"
require "generators/goc/migrations_generator"
require "generators/goc/generator_instructions"

class Goc
  class SetupGenerator < Rails::Generators::Base
    include ModelGenerator
    include RakesGenerator
    include MigrationsGenerator
    include GeneratorInstructions

    source_root File.expand_path("../../templates", __FILE__)

    desc "Setup Goc for some resource"
    class_option :ratings, :domain => :boolean, :default => false, :desc => "Setup goc with ratings-system based"
    class_option :domains, :domain => :boolean, :default => false, :desc => "Setup goc with multiples domains(categories) of badges."

    def execute
      @model_name = ask("What is your resource model?", :default => 'user')
      generate_models
      creating_templates
      adding_methods
      add_validations
      setup_relations
      create_rakes
      configuring_database
      migrating
      instructions
    end

  end
end
