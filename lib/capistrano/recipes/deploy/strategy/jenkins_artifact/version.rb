require 'capistrano/recipes/deploy/strategy/base'

module Capistrano
  module Deploy
    module Strategy
      class JenkinsArtifact < ::Capistrano::Deploy::Strategy::Base
        VERSION = "0.1.0"
      end
    end
  end
end
