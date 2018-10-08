# frozen_string_literal: true

require "spec_helper"
require "new_relic/manticore"

DependencyDetection.detect!

module ::NewRelic
  describe Manticore do
    include Test::Unit::Assertions

    let(:test_uri) { "www.google.com" }

    before do
      NewRelic::Agent.manual_start 
      stub_request(:any, /169.254.169.254/)          # Disable AWS instance identity check
      stub_request(:any, /metadata.google.internal/) # Disable Google cloud instance identity check 
      stub_request(:any, /collector.newrelic.com/)
      stub_request(:any, /#{test_uri}/) 
    end

    it "traces GET requests" do
      in_web_transaction { ::Manticore.get(test_uri, query: {q: "kittens"}) }
      assert_metrics_recorded("External/#{test_uri}/Manticore/GET" => { call_count: 1 })
    end

    it "traces POST requests" do
      in_web_transaction { ::Manticore.post(test_uri, body: "data") }
      assert_metrics_recorded("External/#{test_uri}/Manticore/POST" => { call_count: 1 })
    end
  end
end
