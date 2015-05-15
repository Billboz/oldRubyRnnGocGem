def change_points(options)
  if Goc::Core::DOMAINS
    ratings = options[:ratings]
    domain   = Domain.find(options[:domain])
  else
    ratings = options
    domain   = false
  end

  if Goc::Core::DOMAINS
    raise "Missing Domain Identifier argument" if !domain
    old_pontuation = self.ratings.where(:domain_id => domain.id).sum(:value)
  else
    old_pontuation = self.ratings.to_i
  end
  new_pontuation = old_pontuation + ratings
  Goc::Core.sync_resource_by_points(self, new_pontuation, domain)
end

def next_badge?(domain_id = false)
  if Goc::Core::DOMAINS
    raise "Missing Domain Identifier argument" if !domain_id
    old_pontuation = self.ratings.where(:domain_id => domain_id).sum(:value)
  else
    old_pontuation = self.ratings.to_i
  end
  next_badge       = Badge.where("ratings > #{old_pontuation}").order("ratings ASC").first
  last_badge_point = self.badges.last.try('ratings')
  last_badge_point ||= 0

  if next_badge
    percentage      = (old_pontuation - last_badge_point)*100/(next_badge.ratings - last_badge_point)
    ratings          = next_badge.ratings - old_pontuation
    next_badge_info = {
                        :badge      => next_badge,
                        :ratings     => ratings,
                        :percentage => percentage
                      }
  end
end