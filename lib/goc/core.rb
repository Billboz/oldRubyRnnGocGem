class Goc
  class Core
    def self.get_resource(rid)
      RESOURCE_NAME.capitalize.constantize.find(rid)
    end

    def self.related_info(resource, ratings, domain)
      if DOMAINS && domain
        old_pontuation  = resource.ratings.where(:kind_id => domain.id).sum(:value)
        related_badges  = Badge.where(((old_pontuation < ratings) ? "ratings <= #{ratings}" : "ratings > #{ratings} AND ratings <= #{old_pontuation}") + " AND kind_id = #{domain.id}")
      else
        old_pontuation  = resource.ratings.to_i
        related_badges  = Badge.where((old_pontuation < ratings) ? "ratings <= #{ratings}" : "ratings > #{ratings} AND ratings <= #{old_pontuation}")
      end
      new_pontuation    = ( old_pontuation < ratings ) ? ratings - old_pontuation : - (old_pontuation - ratings)

      { old_pontuation: old_pontuation, related_badges: related_badges, new_pontuation: new_pontuation }
    end

    def self.sync_resource_by_points(resource, ratings, domain = false)

      badges         = {}
      info           = self.related_info(resource, ratings, domain)
      old_pontuation = info[:old_pontuation]
      related_badges = info[:related_badges]
      new_pontuation = info[:new_pontuation]

      Badge.transaction do
          if DOMAINS && domain
          resource.ratings << Rating.create({ :kind_id => domain.id, :value => new_pontuation })
        elsif RATINGS
          resource.update_attribute( :ratings, ratings )
        end
        related_badges.each do |badge|
          if old_pontuation < ratings
            unless resource.badges.include?(badge)
              resource.badges << badge
              badges[:added] = [] if badges[:added].nil?
              badges[:added] << badge
            end
          elsif old_pontuation > ratings
            resource.levels.where( :badge_id => badge.id )[0].destroy
            badges[:removed] = [] if badges[:removed].nil?
            badges[:removed] << badge
          end
        end
        badges
      end
    end
  end
end