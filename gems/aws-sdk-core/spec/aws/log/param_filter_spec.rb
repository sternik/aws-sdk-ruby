require_relative '../../spec_helper'

module Aws
  module Log
    describe ParamFilter do
      let(:service) { 'Peccy Service' }
      let(:hash_filter) { { service => [:password] } }
      let(:array_filter) { [:peccy_name] }

      describe '#initialize' do
        it 'accepts a filter as a hash' do
          filter = ParamFilter.new(filter: hash_filter)
          filters = filter.instance_variable_get(:@filters)
          expect(filters).to include(hash_filter)
        end

        it 'supports a filter as an array (legacy)' do
          filter = ParamFilter.new(filter: array_filter)
          filters = filter.instance_variable_get(:@filters)
          expect(filters.values).to all(include(*array_filter))
        end
      end

      describe '#filter' do
        subject { ParamFilter.new(filter: hash_filter) }

        context 'with an array' do
          it 'filters lowercase parameter names' do
            filtered = subject.filter(service, [{ password: 'p@assw0rd' }])
            expect(filtered).to eq([{ password: '[FILTERED]' }])
          end

          it 'filters uppercase parameter names' do
            filtered = subject.filter(service, [{ PASSWORD: 'p@assw0rd' }])
            expect(filtered).to eq([{ PASSWORD: '[FILTERED]' }])
          end

          it 'filters mixed-case parameter names' do
            filtered = subject.filter(service, [{ Password: 'p@assw0rd' }])
            expect(filtered).to eq([{ Password: '[FILTERED]' }])
          end
        end

        context 'with a Struct' do
          it 'filters lowercase parameter names' do
            instance = Struct.new(:password).new('p@assw0rd')
            filtered = subject.filter(service, instance)
            expect(filtered).to eq(password: '[FILTERED]')
          end

          it 'filters uppercase parameter names' do
            instance = Struct.new(:PASSWORD).new('p@assw0rd')
            filtered = subject.filter(service, instance)
            expect(filtered).to eq(PASSWORD: '[FILTERED]')
          end

          it 'filters mixed-case parameter names' do
            instance = Struct.new(:Password).new('p@assw0rd')
            filtered = subject.filter(service, instance)
            expect(filtered).to eq(Password: '[FILTERED]')
          end
        end

        context 'with a hash' do
          it 'filters lowercase parameter names' do
            filtered = subject.filter(service, password: 'p@ssw0rd')
            expect(filtered).to eq(password: '[FILTERED]')
          end

          it 'filters uppercase parameter names' do
            filtered = subject.filter(service, PASSWORD: 'p@ssw0rd')
            expect(filtered).to eq(PASSWORD: '[FILTERED]')
          end

          it 'filters mixed-case parameter names' do
            filtered = subject.filter(service, Password: 'p@ssw0rd')
            expect(filtered).to eq(Password: '[FILTERED]')
          end
        end
      end
    end
  end
end