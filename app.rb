require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'json'
require 'cfenv'
require 'sprockets'
require 'sprockets-helpers'
Dir['lib/*.rb'].each { |file| require_relative file }

class ComplianceViewer < Sinatra::Base
  attr_reader :compliance_data
  include ZapReport

  def initialize
    super
    @compliance_data = ComplianceData.new
  end

  cloudgov_path = File.join(root, 'node_modules', 'cloudgov-style')

  unless Dir.exist?(cloudgov_path)
    STDERR.puts "Please run `npm install`"
    exit(1)
  end

  set :assets, Sprockets::Environment.new(root)

  configure do
    assets.append_path File.join(root, 'assets')
    assets.append_path File.join(cloudgov_path)

    # minify javascript when in production
    if Sinatra::Base.production?
      assets.js_compressor  = :uglify
    end

    Sprockets::Helpers.configure do |config|
      config.environment = assets
      config.prefix      = '/assets'
      config.digest      = true
    end
  end

  helpers do
    include Sprockets::Helpers
  end

  before do
    cache_control :public, :must_revalidate, max_age: 60
  end

  get '/' do
    erb :index, locals: { data: @compliance_data }
  end

  get '/results' do
    redirect '/'
  end

  get '/results/:name' do |name|
    versions = @compliance_data.versions(name)
    return 'Invalid Project' if versions.count == 0
    erb :results, locals: { versions: versions }
  end

  get '/results/:name/:version' do |name, version|
    version = nil if version == 'current'
    file_data = @compliance_data.file_for(name, version)
    if file_data
      if params['format'] == 'json'
        json JSON.parse @compliance_data.json_for file_data
      else
        erb :report, locals: {
          report_data: ZapReport.create_report(file_data),
          project_name: name,
          project_version: version || 'current',
          project_time: file_data.last_modified
        }
      end
    else
      'Invalid Version'
    end
  end
end
