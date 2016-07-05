require 'uri'

require 'capistrano/recipes/deploy/strategy/base'
require 'jenkins_api_client'

class ::JenkinsApi::Client::Job
  def get_last_successful_build_number(job_name, branch)
    @logger.info "Obtaining last successful build number of #{job_name}"
    res = @client.api_get_request("/job/#{path_encode(job_name)}/lastSuccessfulBuild")
    res['number']
  end
end

class ::Capistrano::Deploy::Strategy::JenkinsArtifact < ::Capistrano::Deploy::Strategy::Base
  def deploy!
    jenkins_origin = fetch(:jenkins_origin) or abort ":jenkins_origin configuration must be defined"
    client = JenkinsApi::Client.new(server_url: jenkins_origin.to_s)
    set(:artifact_url) do
      uri = client.job.find_artifact(fetch(:build_project)) or abort "No artifact found for #{fetch(:build_project)}"
      URI.parse(uri).tap {|uri|
        uri.scheme = jenkins_origin.scheme
        uri.host = jenkins_origin.host
        uri.port = jenkins_origin.port
      }.to_s
    end

    build_num = client.job.get_last_successful_build_number(fetch(:build_project), "origin/#{fetch(:branch)}")
    timestamp = client.job.get_build_details(fetch(:build_project), build_num)['timestamp']
    deploy_at = Time.at(timestamp / 1000)

    set(:release_name, deploy_at.strftime('%Y%m%d%H%M%S'))
    set(:release_path, "#{fetch(:releases_path)}/#{fetch(:release_name)}")
    set(:latest_release, fetch(:release_path))

    run <<-SCRIPT
      mkdir -p #{fetch(:release_path)} && \
      (curl -s #{fetch(:artifact_url)} | \
      tar --strip-components=1 -C #{fetch(:release_path)} -jxf -)
    SCRIPT
  end
end
