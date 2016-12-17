require 'uri'

require 'capistrano/recipes/deploy/strategy/base'
require 'jenkins_api_client'

class ::JenkinsApi::Client::Job
  def get_last_successful_build_number(job_name)
    @logger.info "Obtaining last successful build number of #{job_name}"
    res = @client.api_get_request("/job/#{path_encode(job_name)}/lastSuccessfulBuild")
    res['number']
  end

  def find_artifact_with_path(job_name, relative_path)
    current_build_number  = get_current_build_number(job_name)
    job_path              = "job/#{path_encode job_name}/"
    response_json         = @client.api_get_request("/#{job_path}#{current_build_number}")
    if response_json['artifacts'].none? {|a| a['relativePath'] == relative_path }
      abort "Specified artifact not found in curent_build !!"
    end
    jenkins_path          = response_json['url']
    artifact_path         = URI.escape("#{jenkins_path}artifact/#{relative_path}")
    return artifact_path
  end
end

class ::Capistrano::Deploy::Strategy::JenkinsArtifact < ::Capistrano::Deploy::Strategy::Base
  def deploy!
    dir_name = exists?(:is_multibranch_job) && fetch(:is_multibranch_job) ? fetch(:branch) : fetch(:build_project)

    jenkins_origin = fetch(:jenkins_origin) or abort ":jenkins_origin configuration must be defined"
    client = JenkinsApi::Client.new(server_url: jenkins_origin.to_s)
    set(:artifact_url) do
      uri = ''
      if exists?(:artifact_relative_path)
        uri = client.job.find_artifact_with_path(dir_name, fetch(:artifact_relative_path))
      else
        uri = client.job.find_artifact(dir_name)
      end
      abort "No artifact found for #{dir_name}" if uri.empty?
      URI.parse(uri).tap {|uri|
        uri.scheme = jenkins_origin.scheme
        uri.host = jenkins_origin.host
        uri.port = jenkins_origin.port
      }.to_s
    end

    build_num = client.job.get_last_successful_build_number(dir_name, "origin/#{fetch(:branch)}")
    timestamp = client.job.get_build_details(dir_name, build_num)['timestamp']
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
