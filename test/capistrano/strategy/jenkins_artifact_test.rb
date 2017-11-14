require 'test_helper'

require 'webmock/minitest'
require 'json'

require 'capistrano/recipes/deploy/strategy/jenkins_artifact'

class Capistrano::Deploy::Strategy::JenkinsArtifactTest < Minitest::Test
  def test_get_last_successful_build
    jenkins_origin = 'http://example.com'
    job = 'example-job'
    stub_get = stub_request(:get, "#{jenkins_origin}/job/#{job}/lastSuccessfulBuild/api/json").
      to_return(
        body: JSON.generate({
          'timestamp' => Time.now.to_i,
          'artifacts' => [
            { 'displayPath' => 'artifact.tar.gz', 'fileName' => 'artifact.tar.gz', 'relativePath' => 'artifact.tar.gz' },
            { 'displayPath' => 'another.tar.gz',  'fileName' => 'another.tar.gz',  'relativePath' => 'another.tar.gz' },
          ],
          'url' => 'http://example.com/',
        }),
        headers: { 'content-type' => 'application/json' },
      )
    build = Capistrano::Deploy::Strategy::JenkinsArtifact::ApiClient.get_last_successful_build(jenkins_origin, job)
    refute_nil(build)
    assert_requested(stub_get)
  end

  def test_get_last_successful_build_fail
    jenkins_origin = 'http://example.com'
    job = 'example-job'
    stub_get = stub_request(:get, "#{jenkins_origin}/job/#{job}/lastSuccessfulBuild/api/json").
      to_return(
        body: 'Internal Server Error',
        status: 500,
      )
    assert_raises(JenkinsApi::Exceptions::InternalServerError) {
      Capistrano::Deploy::Strategy::JenkinsArtifact::ApiClient.get_last_successful_build(jenkins_origin, job)
    }
    assert_requested(stub_get)
  end
end
