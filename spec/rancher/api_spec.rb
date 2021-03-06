require 'spec_helper'

describe Rancher::Api do
  it 'has a version number' do
    expect(Rancher::Api::VERSION).not_to be nil
  end

  context '#configure' do
    before do
      subject.configure do |config|
        config.url = 'http://example.com/v2-beta'
      end
    end

    it 'should keep configuration instance' do
      expect(subject.configuration.url).to eq('http://example.com/v2-beta')
    end

    context '#reset' do
      before { subject.reset }

      it 'should reset configuration instance' do
        expect(subject.configuration.url).to be_nil
      end
    end
  end
end
