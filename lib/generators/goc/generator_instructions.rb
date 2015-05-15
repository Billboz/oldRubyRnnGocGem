# encoding: utf-8
module GeneratorInstructions
	def instructions
		puts <<-EOS

=======================================================

Goc successfully installed.

Now you are able to add Badges using:
  rake goc:add_badge[BADGE_NAME#{",RATINGS" if options[:ratings]}#{",KIND_NAME" if options[:domains]},DEFAULT]

To remove Badges using:
  rake goc:remove_badge[BADGE_NAME#{",KIND_NAME" if options[:domains]}]

#{
  if options[:domains]
"And to remove Domains using:
  rake goc:remove_domain[KIND_NAME]"
  end
}

For usage and more infomation go to the documentation:
http://joaomdmoura.github.com/goc/

By João Moura (a.k.a joaomdmoura)

=======================================================

		EOS
	end
end