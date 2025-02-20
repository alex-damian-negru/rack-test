# frozen_string_literal: true

require 'spec_helper'

describe Rack::Test::Utils do
  include described_class

  describe 'build_nested_query' do
    it 'converts empty strings to =' do
      expect(build_nested_query('')).to eq('=')
    end

    it 'converts nil to an empty string' do
      expect(build_nested_query(nil)).to eq('')
    end

    it 'converts hashes with nil values' do
      expect(build_nested_query(a: nil)).to eq('a')
    end

    it 'converts hashes' do
      expect(build_nested_query(a: 1)).to eq('a=1')
    end

    it 'converts hashes with multiple keys' do
      hash = { a: 1, b: 2 }
      expect(['a=1&b=2', 'b=2&a=1']).to include(build_nested_query(hash))
    end

    it 'converts arrays with one element' do
      expect(build_nested_query(a: [1])).to eq('a[]=1')
    end

    it 'converts arrays with multiple elements' do
      expect(build_nested_query(a: [1, 2])).to eq('a[]=1&a[]=2')
    end

    it "converts arrays with brackets '[]' in the name" do
      expect(build_nested_query('a[]' => [1, 2])).to eq('a%5B%5D=1&a%5B%5D=2')
    end

    it 'converts nested hashes' do
      expect(build_nested_query(a: { b: 1 })).to eq('a[b]=1')
    end

    it 'converts arrays nested in a hash' do
      expect(build_nested_query(a: { b: [1, 2] })).to eq('a[b][]=1&a[b][]=2')
    end

    it 'converts arrays of hashes' do
      expect(build_nested_query(a: [{ b: 2 }, { c: 3 }])).to eq('a[][b]=2&a[][c]=3')
    end

    it 'supports hash keys with empty arrays' do
      input = { collection: [] }
      expect(build_nested_query(input)).to eq('collection[]=')
    end
  end

  describe 'Rack::Test::Utils.build_multipart' do
    it 'builds multipart bodies' do
      files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
      data = described_class.build_multipart('submit-name' => 'Larry', 'files' => files)

      options = {
        'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
        'CONTENT_LENGTH' => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for('/', options)
      params = Rack::Multipart.parse_multipart(env)
      expect(params['submit-name']).to eq('Larry')
      expect(params['files'][:filename]).to eq('foo.txt')
      expect(params['files'][:tempfile].read).to eq("bar\n")
    end

    it 'builds multipart bodies from array of files' do
      files = [Rack::Test::UploadedFile.new(multipart_file('foo.txt')), Rack::Test::UploadedFile.new(multipart_file('bar.txt'))]
      data = described_class.build_multipart('submit-name' => 'Larry', 'files' => files)

      options = {
        'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
        'CONTENT_LENGTH' => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for('/', options)
      params = Rack::Multipart.parse_multipart(env)
      expect(params['submit-name']).to eq('Larry')

      expect(params['files'][0][:filename]).to eq('foo.txt')
      expect(params['files'][0][:tempfile].read).to eq("bar\n")

      expect(params['files'][1][:filename]).to eq('bar.txt')
      expect(params['files'][1][:tempfile].read).to eq("baz\n")
    end

    it 'builds nested multipart bodies' do
      files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
      data = described_class.build_multipart('people' => [{ 'submit-name' => 'Larry', 'files' => files }], 'foo' => %w[1 2])

      options = {
        'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
        'CONTENT_LENGTH' => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for('/', options)
      params = Rack::Multipart.parse_multipart(env)
      expect(params['people'][0]['submit-name']).to eq('Larry')
      expect(params['people'][0]['files'][:filename]).to eq('foo.txt')
      expect(params['people'][0]['files'][:tempfile].read).to eq("bar\n")
      expect(params['foo']).to eq(%w[1 2])
    end

    it 'builds nested multipart bodies with an array of hashes' do
      files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
      data = described_class.build_multipart('files' => files, 'foo' => [{ 'id' => '1', 'name' => 'Dave' }, { 'id' => '2', 'name' => 'Steve' }])

      options = {
        'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
        'CONTENT_LENGTH' => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for('/', options)
      params = Rack::Multipart.parse_multipart(env)
      expect(params['files'][:filename]).to eq('foo.txt')
      expect(params['files'][:tempfile].read).to eq("bar\n")
      expect(params['foo']).to eq([{ 'id' => '1', 'name' => 'Dave' }, { 'id' => '2', 'name' => 'Steve' }])
    end

    it 'builds nested multipart bodies with arbitrarily nested array of hashes' do
      files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
      nested = [
        { 'id' => '1', 'name' => 'Dave' },
        { 'id' => '2', 'name' => 'Steve', 'qux' => [{ 'id' => '3', 'name' => 'mike' }, { 'id' => '4', 'name' => 'Joan' }] }
      ]
      data = described_class.build_multipart('files' => files, 'foo' => { 'bar' => nested })

      options = {
        'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
        'CONTENT_LENGTH' => data.length.to_s,
        :input => StringIO.new(data)
      }
      env = Rack::MockRequest.env_for('/', options)
      params = Rack::Multipart.parse_multipart(env)
      expect(params['files'][:filename]).to eq('foo.txt')
      expect(params['files'][:tempfile].read).to eq("bar\n")
      expect(params['foo']).to eq('bar' => nested)
    end

    context 'with seemingly, but non-nested params' do
      subject(:params) do
        files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
        data = described_class.build_multipart('foo[]' => '1', 'bar[]' => { 'qux' => '2' }, 'files[]' => files)
        options = {
          'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
          'CONTENT_LENGTH' => data.length.to_s,
          :input => StringIO.new(data)
        }
        env = Rack::MockRequest.env_for('/', options)
        Rack::Multipart.parse_multipart(env)
      end

      its(['files', 0, :filename]) { is_expected.to eq 'foo.txt' }
      its(['foo', 0]) { is_expected.to eq '1' }
      its(['bar', 0]) { is_expected.to eq({ 'qux' => '2' }) }

      it 'has the correct file content' do
        expect(params['files'][0][:tempfile].read).to eq "bar\n"
      end
    end

    context 'with nested files' do
      subject(:params) do
        files = Rack::Test::UploadedFile.new(multipart_file('foo.txt'))
        data = described_class.build_multipart('foo' => [{ 'id' => '1', 'data' => files }, { 'id' => '2', 'data' => %w[3 4] }])
        options = {
          'CONTENT_TYPE' => "multipart/form-data; boundary=#{Rack::Test::MULTIPART_BOUNDARY}",
          'CONTENT_LENGTH' => data.length.to_s,
          input: StringIO.new(data)
        }
        env = Rack::MockRequest.env_for('/', options)

        Rack::Multipart.parse_multipart(env)
      end

      its(['foo', 0, 'id']) { is_expected.to eq '1' }
      its(['foo', 0, 'data', :filename]) { is_expected.to eq 'foo.txt' }
      its(['foo', 1]) { is_expected.to eq({ 'id' => '2', 'data' => %w[3 4] }) }

      it 'has the correct file content' do
        expect(params['foo'][0]['data'][:tempfile].read).to eq "bar\n"
      end
    end

    it 'returns nil if no UploadedFiles were used' do
      data = described_class.build_multipart('people' => [{ 'submit-name' => 'Larry', 'files' => 'contents' }])
      expect(data).to be_nil
    end

    it 'raises ArgumentErrors if params is not a Hash' do
      expect do
        described_class.build_multipart('foo=bar')
      end.to raise_error(ArgumentError, 'value must be a Hash')
    end

    def multipart_file(name)
      File.join(File.dirname(__FILE__), '..', '..', 'fixtures', name.to_s)
    end
  end
end
