module MigrationsGenerator
 def migrating
    puts <<-EOS

=======================================
> Running rake db:migrate
=======================================

    EOS
    rake("db:migrate")
  end

  def configuring_database
    empty_directory "db/goc"
    create_file "db/goc/db.rb"
  end
end