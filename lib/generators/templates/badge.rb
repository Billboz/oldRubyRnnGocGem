def add(resource_id)
  resource = Goc::Core.get_resource(resource_id)

  if Goc::Core::RATINGS && !resource.badges.include?(self)
    if Goc::Core::DOMAINS
      Goc::Core.sync_resource_by_points(resource, self.ratings, self.domain)
    else
      Goc::Core.sync_resource_by_points(resource, self.ratings)
    end
  elsif !resource.badges.include?(self)
    resource.badges << self
    return self
  end
end

def remove(resource_id)
  resource = Goc::Core.get_resource(resource_id)

  if Goc::Core::RATINGS && resource.badges.include?(self)
    if Goc::Core::DOMAINS
      domain       = self.domain
      badges_gap = Badge.where( "ratings < #{self.ratings} AND domain_id = #{domain.id}" ).order('ratings DESC')[0]
      Goc::Core.sync_resource_by_points( resource, ( badges_gap.nil? ) ? 0 : badges_gap.ratings, domain)
    else
      badges_gap = Badge.where( "ratings < #{self.ratings}" ).order('ratings DESC')[0]
      Goc::Core.sync_resource_by_points( resource, ( badges_gap.nil? ) ? 0 : badges_gap.ratings)
    end
  elsif resource.badges.include?(self)
    resource.levels.where( :badge_id => self.id )[0].destroy
    return self
  end
end