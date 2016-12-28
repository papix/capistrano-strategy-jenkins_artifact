require 'test_helper'

require 'json'
require 'webmock/minitest'

require 'capistrano/recipes/deploy/strategy/jenkins_artifact'

class JenkinsApi::Client::JobTest < Minitest::Test
  def test_get_artifact_url_by_build
    build = {
      'artifacts' => [
        { 'displayPath' => 'artifact.tar.gz', 'fileName' => 'artifact.tar.gz', 'relativePath' => 'artifact.tar.gz' },
        { 'displayPath' => 'another.tar.gz',  'fileName' => 'another.tar.gz',  'relativePath' => 'another.tar.gz' },
      ],
      'url' => 'http://example.com/',
    }

    got_artifact_path = JenkinsApi::Client::Job.get_artifact_url_by_build(build)
    assert_match %r{\bartifact\.tar\.gz\z}, got_artifact_path

    got_artifact_path = JenkinsApi::Client::Job.get_artifact_url_by_build(build) {|artifact| artifact['relativePath'] == 'another.tar.gz' }
    assert_match %r{\banother\.tar\.gz\z}, got_artifact_path
  end
end

