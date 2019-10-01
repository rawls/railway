# frozen_string_literal: true

require 'sinatra/base'
require 'nokogiri'

class LDBWSDummy < Sinatra::Base
  FIXTURE_FOLDER = File.dirname(__FILE__) + '/../fixtures/ldbws/'

  post '/OpenLDBWS/ldb11.asmx' do
    content_type(:xml)
    status(200)
    action = request.env['HTTP_SOAPACTION'].split('/').last
    xml = Nokogiri::XML(request.body)
    xml.remove_namespaces!
    crs = xml.xpath('//crs').first.text
    File.open(FIXTURE_FOLDER + "/#{action}/#{crs}/response.xml", 'rb').read
  rescue StandardError => e
    STDOUT.puts "LDBWS Dummy Error: #{e.class} - #{e.message} (#{e.backtrace.first})"
    status 404
    'Test not found'
  end
end
