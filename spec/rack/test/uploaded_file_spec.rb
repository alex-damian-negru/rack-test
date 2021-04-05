# frozen_string_literal: true

require 'spec_helper'

describe Rack::Test::UploadedFile do
  def test_file_path
    "#{File.dirname(__FILE__)}/../../fixtures/foo.txt"
  end

  it 'returns an instance of `Rack::Test::UploadedFile`' do
    uploaded_file = described_class.new(test_file_path)

    expect(uploaded_file).to be_a(described_class)
  end

  it 'responds to things that Tempfile responds to' do
    uploaded_file = described_class.new(test_file_path)

    Tempfile.public_instance_methods(false).each do |method|
      expect(uploaded_file).to respond_to(method)
    end
  end

  it "creates Tempfiles with original file's extension" do
    uploaded_file = described_class.new(test_file_path)

    expect(File.extname(uploaded_file.path)).to eq('.txt')
  end

  it 'creates Tempfiles with a path that includes a single extension' do
    uploaded_file = described_class.new(test_file_path)

    regex = /foo#{Time.now.year}.*\.txt\Z/
    expect(uploaded_file.path).to match(regex)
  end

  context 'it should call its destructor' do
    it 'calls the destructor' do
      expect(described_class).to receive(:actually_finalize).at_least(:once)

      if RUBY_PLATFORM == 'java'
        require 'java'
        java_import 'java.lang.System'

        50.times do |_i|
          described_class.new(test_file_path)
          System.gc
        end
      else
        50.times do |_i|
          described_class.new(test_file_path)
          GC.start
        end
      end
    end
  end

  describe '#initialize' do
    context 'with an IO object' do
      subject { -> { uploaded_file } }

      let(:stringio) { StringIO.new('I am content') }
      let(:uploaded_file) { described_class.new(stringio, original_filename: original_filename) }

      context 'with an original filename' do
        let(:original_filename) { 'content.txt' }

        it 'sets the specified filename' do
          subject.call
          expect(uploaded_file.original_filename).to eq(original_filename)
        end
      end
    end
  end
end
