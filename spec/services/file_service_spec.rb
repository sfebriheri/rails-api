require 'rails_helper'

RSpec.describe FileService, type: :service do
  describe '.validate_and_save_pdf' do
    let(:user_id) { 1 }
    let(:valid_pdf_path) { Rails.root.join('spec', 'fixtures', 'sample.pdf') }

    before do
      # Create fixtures directory
      FileUtils.mkdir_p(Rails.root.join('spec', 'fixtures'))
    end

    context 'with valid PDF' do
      before do
        # Create a minimal valid PDF for testing
        File.write(valid_pdf_path, "%PDF-1.4\n%fake pdf content")
      end

      after do
        File.delete(valid_pdf_path) if File.exist?(valid_pdf_path)
      end

      it 'raises error when file is blank' do
        expect {
          FileService.validate_and_save_pdf(nil, user_id)
        }.to raise_error(FileService::InvalidFileError, /File is required/)
      end

      it 'raises error when user_id is blank' do
        file = double('file', blank?: false)
        expect {
          FileService.validate_and_save_pdf(file, nil)
        }.to raise_error(FileService::InvalidFileError, /User ID is required/)
      end
    end

    context 'with file validation' do
      it 'raises error for empty file' do
        file = double('file',
          size: 0,
          blank?: false,
          content_type: 'application/pdf',
          original_filename: 'test.pdf'
        )
        expect {
          FileService.validate_and_save_pdf(file, user_id)
        }.to raise_error(FileService::InvalidFileError, /File is empty/)
      end

      it 'raises error for file exceeding size limit' do
        file = double('file',
          size: 100.megabytes,
          blank?: false,
          content_type: 'application/pdf',
          original_filename: 'test.pdf'
        )
        expect {
          FileService.validate_and_save_pdf(file, user_id)
        }.to raise_error(FileService::FileTooLargeError)
      end

      it 'raises error for invalid content type' do
        file = double('file',
          size: 1000,
          blank?: false,
          content_type: 'application/txt',
          original_filename: 'test.txt'
        )
        expect {
          FileService.validate_and_save_pdf(file, user_id)
        }.to raise_error(FileService::InvalidFileError, /Invalid file type/)
      end

      it 'raises error for invalid extension' do
        file = double('file',
          size: 1000,
          blank?: false,
          content_type: 'application/pdf',
          original_filename: 'test.doc'
        )
        expect {
          FileService.validate_and_save_pdf(file, user_id)
        }.to raise_error(FileService::InvalidFileError, /Invalid file extension/)
      end
    end
  end

  describe '.safe_delete_file' do
    let(:upload_dir) { Rails.root.join('storage', 'uploads') }
    let(:test_file_path) { upload_dir.join('test-file.pdf') }

    before do
      FileUtils.mkdir_p(upload_dir)
      File.write(test_file_path, 'test content')
    end

    after do
      FileUtils.rm_rf(upload_dir)
    end

    it 'deletes file when path is valid' do
      expect(File.exist?(test_file_path)).to be true
      FileService.safe_delete_file(test_file_path.to_s)
      expect(File.exist?(test_file_path)).to be false
    end

    it 'handles missing files gracefully' do
      expect {
        FileService.safe_delete_file('/nonexistent/file.pdf')
      }.not_to raise_error
    end

    it 'prevents path traversal attacks' do
      malicious_path = '/etc/passwd'
      expect {
        FileService.safe_delete_file(malicious_path)
      }.not_to raise_error
      # File should not be deleted
      expect(File.exist?(malicious_path)).to be false
    end
  end
end
