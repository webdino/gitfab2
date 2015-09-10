module ActsAsVotable
  module Votable
    module Decorators
      def count_label
        labelify cached_votes_score
      end

      def increased_count_label
        labelify(cached_votes_score + 1)
      end

      def decreased_count_label
        labelify(cached_votes_score - 1)
      end

      private

      def labelify(score)
        score > 0 ? score.to_s : ''
      end
    end
    include Decorators
  end
end
