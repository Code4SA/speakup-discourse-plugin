# name: embed-by-topic-id
# about: embed discourse topics by id
# version: 0.1
# authors: Greg Kempe @longhotsummer

after_initialize do

  TopicEmbed.class_eval do
    class << self
      alias_method :old_topic_id_for_embed, :topic_id_for_embed

      def topic_id_for_embed(embed_url)
        # just a number
        return embed_url.to_i if embed_url =~ /^[0-9]+$/

        # /t/do-you-have-a-job/43/1
        if embed_url =~ %r{^/t/[^/]+/([0-9]+)}
          return $1
        end

        # fall back to old mechanism
        old_topic_id_for_embed
      end
    end
  end

end
