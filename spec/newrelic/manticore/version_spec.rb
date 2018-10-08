# frozen_string_literal: true

require "spec_helper"

describe Newrelic::Manticore do
  it "has a version number" do
    expect(Newrelic::Manticore::VERSION).not_to be nil
  end
end
