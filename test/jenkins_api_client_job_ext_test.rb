require 'test_helper'

require 'json'
require 'webmock/minitest'

require 'capistrano/recipes/deploy/strategy/jenkins_artifact'

class JenkinsApi::Client::JobTest < Minitest::Test
  def test_find_last_successful_artifact
    jenkins_origin = 'http://jenkins.example.com'
    api_client = JenkinsApi::Client.new(server_url: jenkins_origin)
    job_name = 'test-job'
    stub_request(:get, %r{/job/[^/]+/lastSuccessfulBuild\b}).to_return {|req|
      artifacts = [
        { displayPath: 'artifact.tar.gz', fileName: 'artifact.tar.gz', relativePath: 'artifact.tar.gz' },
        { displayPath: 'another.tar.gz', fileName: 'another.tar.gz', relativePath: 'another.tar.gz' },
      ]
      { body: JSON.generate(number: 123, artifacts: artifacts), status: 200 }
    }

    got_artifact_path = api_client.job.find_last_successful_artifact(job_name)
    assert_match %r{\bartifact\.tar\.gz\z}, got_artifact_path

    got_artifact_path = api_client.job.find_last_successful_artifact(job_name) {|artifact| artifact['relativePath'] == 'another.tar.gz' }
    assert_match %r{\banother\.tar\.gz\z}, got_artifact_path
  end
end
