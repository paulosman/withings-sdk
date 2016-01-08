require 'spec_helper'

describe WithingsSDK::Base do
  let (:base) { WithingsSDK::Base.new(foo: 'bar') }

  describe '#attrs' do
    it 'returns a hash of attributes' do
      expect(base.attrs).to eq(foo: 'bar')
    end
  end

  describe '#initialize' do
    context 'when given constructor params' do
      it 'sets instance variables' do
        expect(base.foo).to eq('bar')
      end
    end
  end
end
