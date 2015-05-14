module RakesGenerator
  def create_rakes
  rakefile 'goc.rake' do
        <<-EOS
# -*- encoding: utf-8 -*-
namespace :goc do

  desc "Used to add a new badge at Goc scheme"

  task :add_badge, [:name, #{":ratings, " if options[:ratings]}#{":domain, " if options[:domains]}:default] => :environment do |t, args|
    arg_default = ( args.default ) ? eval(args.default) : false


    if !args.name #{"|| !args.ratings" if options[:ratings]}#{" || !args.domain" if options[:domains]}
      raise "There are missing some arguments"
    else
      badge_string = "#{options[:domains] ? 'domain = Domain.find_or_create_by(name: \'#{args.domain}\')\n' : ''}"

      badge_string = badge_string + "badge = Badge.where 'name = ? AND kind_id = ?', '#\{args.name\}', #{"domain.id" if options[:domains]}\n
                    if badge.empty?
                      badge = Badge.create({
                        name: \'\#\{args.name\}\',
                        #{"ratings: \'\#\{args.ratings\}\'," if options[:ratings]}
                        #{"kind_id: domain.id," if options[:domains]}
                        default: \'\#\{arg_default\}\'
                      })
                    else
                      raise 'There is another badge with this name related with this domain'
                    end\n"

      if arg_default
        badge_string = badge_string + 'resources = #{@model_name.capitalize}.find(:all)\n'
        badge_string = badge_string + "resources.each do |r|
        #{
        if options[:ratings] && options[:domains]
            "r.ratings  << Rating.create({ :kind_id => domains.id, :value => \'\#\{args.ratings\}\'})"
        elsif options[:ratings]
          "r.ratings = \'\#\{args.ratings\}\'"
        end
        }
          r.badges << badge
          r.save!
        end\n"
      end

      badge_string = badge_string + "puts '> Badge successfully created'"

      eval badge_string

      file_path = "/db/goc/create_badge_\#\{args.name\}#{"_\#\{args.domain\}" if options[:domains]}.rb"
      File.open("\#\{Rails.root\}\#\{file_path\}", 'w') { |f| f.write badge_string }
      File.open("\#\{Rails.root\}/db/goc/db.rb", 'a') { |f| f.write "require \\"\\#\\{Rails.root\\}\#\{file_path\}\\"\n" }

    end

  end

  desc "Used to remove an old badge at Goc scheme"

  task :remove_badge, [:name#{", :domain" if options[:domains]}] => :environment do |t, args|
    if !args.name#{" || !args.domain" if options[:domains]}
      raise "There are missing some arguments"
    else
      badge_string = "#{"domain = Domain.find_by_name('\#\{args.domain\}')" if options[:domains]}
      badge = Badge.where( :name => '\#\{args.name\}'#{", :kind_id => domain.id" if options[:domains]} ).first
      badge.destroy\n"
    end

    badge_string = badge_string + "puts '> Badge successfully removed'"

    eval badge_string

    file_path = "/db/goc/remove_badge_\#\{args.name\}.rb"
    File.open("\#\{Rails.root\}\#\{file_path\}", 'w') { |f| f.write badge_string }
    File.open("\#\{Rails.root\}/db/goc/db.rb", 'a') { |f| f.write "require \\"\\#\\{Rails.root\\}\#\{file_path\}\\"\n" }
  end
#{
if options[:domains]
  '
  desc "Removes a given domain"
  task :remove_kind, [:name] => :environment do |t, args|
    if !args.name
      raise "There are missing some arguments"
    else
      kind_string = "domain = Domain.find_by_name( \'#{args.name}\' )\n"
      kind_string = kind_string + "if domain.badges.empty?
        domain.destroy
      else
        raise \'Aborted! There are badges related with this domain.\'
      end\n"
    end
    kind_string = kind_string + "puts \'> Domain successfully removed\'"
    eval kind_string

    file_path = "/db/goc/remove_kind_#{args.name}.rb"
    File.open("#{Rails.root}#{file_path}", "w") { |f| f.write kind_string }
    File.open("#{Rails.root}/db/goc/db.rb", "a") { |f| f.write "require \\"\\#\\{Rails.root\\}#{file_path}\\"\n" }
  end
  '
end
}
  task :sync_database => :environment do
    content = File.read("#{Rails.root}/db/goc/db.rb")
    eval content
  end
end
        EOS
      end
  end
end