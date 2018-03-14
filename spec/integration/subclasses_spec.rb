require 'spec_helper'

describe Mongoid::History::Tracker do
  before :all do
    class Element
      include Mongoid::Document
      include Mongoid::Timestamps

      field :body
    end

    class Prompt < Element
      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::History::Trackable

      field :dirty, type: Boolean, default: false

      track_history(
        on: [:fields],
        modifier_field: :updater,
        track_create: true,
        track_update: true,
        track_destroy: true
      )
    end
  end

  it 'tracks subclass create and update' do
    prompt = Prompt.new
    expect { prompt.save! }.to change(Tracker, :count).by(1)
    expect { prompt.update_attributes!(dirty: true) }.to change(Tracker, :count).by(1)
    prompt.undo!
    expect(prompt.dirty).to be_blank
    prompt.redo! nil, 2
    expect(prompt.dirty).to be(true)
    expect { prompt.destroy }.to change(Tracker, :count).by(1)
  end
end
