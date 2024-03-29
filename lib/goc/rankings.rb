class Goc
  class Ranking < Core

    def self.with_domain_and_points
      ranking = []
      Domain.all.each do |t|
        data = RESOURCE_NAME.capitalize.constantize
                .select("#{RESOURCE_NAME.capitalize.constantize.table_name}.*, 
                         ratings.domain_id, SUM(ratings.value) AS domain_points")
                .where("ratings.domain_id = #{t.id}")
                .joins(:ratings)
                .group("domain_id, #{RESOURCE_NAME}_id")
                .order("domain_points DESC")

        ranking << { :domain => t, :ranking => data }
      end
      ranking
    end

    def self.without_domain_and_points
      ranking = RESOURCE_NAME.capitalize.constantize
                  .select("#{RESOURCE_NAME.capitalize.constantize.table_name}.*,
                           COUNT(levels.badge_id) AS number_of_levels")
                  .joins(:levels)
                  .group("#{RESOURCE_NAME}_id")
                  .order("number_of_levels DESC")
    end

    def self.generate
      ranking = []
      if RATINGS && DOMAINS
        ranking = self.with_domain_and_points
      elsif RATINGS && !DOMAINS
        ranking = RESOURCE_NAME.capitalize.constantize.order("ratings DESC")
      elsif !RATINGS && !DOMAINS
        ranking = without_domain_and_points
      end
      ranking
    end
  end
end
