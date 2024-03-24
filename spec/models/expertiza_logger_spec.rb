require 'rails_helper'

RSpec.describe ExpertizaLogger do
  let(:log_message) { 'Test log message' }

  before do
    # Delete all log files before each test
    Dir[Rails.root.join('log', 'expertiza_*.log')].each do |file|
      File.delete(file)
    end
  end

  after do
    # Delete all log files after each test
    Dir[Rails.root.join('log', 'expertiza_*.log')].each do |file|
      File.delete(file)
    end
  end

  describe '.info' do
    let(:log_file_path) { Rails.root.join('log', 'expertiza_info.log') }

    it 'logs an info message' do
      ExpertizaLogger.info(log_message)
      expect(File.read(log_file_path)).to include(log_message)
    end
  end

  describe '.warn' do
    let(:log_file_path) { Rails.root.join('log', 'expertiza_warn.log') }

    it 'logs a warn message' do
      ExpertizaLogger.warn(log_message)
      expect(File.read(log_file_path)).to include(log_message)
    end
  end

  describe '.error' do
    let(:log_file_path) { Rails.root.join('log', 'expertiza_error.log') }

    it 'logs an error message' do
      ExpertizaLogger.error(log_message)
      expect(File.read(log_file_path)).to include(log_message)
    end
  end

  describe '.fatal' do
    let(:log_file_path) { Rails.root.join('log', 'expertiza_fatal.log') }

    it 'logs a fatal message' do
      ExpertizaLogger.fatal(log_message)
      expect(File.read(log_file_path)).to include(log_message)
    end
  end

  describe '.debug' do
    let(:log_file_path) { Rails.root.join('log', 'expertiza_debug.log') }

    it 'logs a debug message' do
      ExpertizaLogger.debug(log_message)
      expect(File.read(log_file_path)).to include(log_message)
    end
  end
end