require 'test_helper'

class Capistrano::Strategy::JenkinsArtifactTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Capistrano::Strategy::JenkinsArtifact::VERSION
  end
end
