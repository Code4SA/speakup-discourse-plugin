module MiniCmsPlugin
  class Engine < ::Rails::Engine
    engine_name 'mini_cms'
    isolate_namespace MiniCmsPlugin
  end

  Engine.routes.draw do
    get '/homepage-banner' => 'mini_cms#homepage_banner'
  end

  class MiniCmsController < ActionController::Base
    def homepage_banner
      topic = Topic.where(
        category: Category.where(name: 'Staff'),
        title: 'Homepage Banner').first

      if topic
        post = topic.ordered_posts.last
        if post
          render json: {cooked: post.cooked}
          return
        end
      end

      render json: {cooked: ''}
    end
  end

end
