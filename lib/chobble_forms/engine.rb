# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module ChobbleForms
  class Engine < ::Rails::Engine
    extend T::Sig
    isolate_namespace ChobbleForms

    initializer "chobble_forms.add_view_paths" do |app|
      ActiveSupport.on_load(:action_controller) do
        T.unsafe(self).prepend_view_path ChobbleForms::Engine.root.join("views")
      end
    end

    config.to_prepare do
      ApplicationController.helper(ChobbleForms::Helpers)
    end

    initializer "chobble_forms.view_helpers" do
      ActiveSupport.on_load(:action_view) do
        include ChobbleForms::Helpers
      end
    end

    # Asset pipeline configuration
    initializer "chobble_forms.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets
        app.config.assets.paths << root.join("app/assets/stylesheets")
        app.config.assets.paths << root.join("app/javascript")
        app.config.assets.precompile += %w[chobble_forms.css]
      end
    end
  end
end
