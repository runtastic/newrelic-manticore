# frozen_string_literal: true

require "spec_helper"
require "new_relic/manticore"

describe NewRelic::Manticore do
  it "has a version number" do
    expect(NewRelic::Manticore::VERSION).not_to be nil
  end
end
