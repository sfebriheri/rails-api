require 'rails_helper'

RSpec.describe EvaluationJob, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:job_id) }
    it { is_expected.to validate_presence_of(:job_title) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:cv_document_id) }
    it { is_expected.to validate_presence_of(:project_document_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:cv_document).class_name('Document') }
    it { is_expected.to belong_to(:project_document).class_name('Document') }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'status transitions' do
    let(:evaluation_job) { create(:evaluation_job) }

    it 'starts in queued status' do
      expect(evaluation_job.status).to eq('queued')
    end

    it 'transitions from queued to processing' do
      evaluation_job.start_processing!
      expect(evaluation_job.status).to eq('processing')
    end

    it 'transitions from processing to completed' do
      evaluation_job.start_processing!
      evaluation_job.complete!(
        cv_match_rate: 0.85,
        cv_feedback: 'Good CV',
        project_score: 4.5,
        project_feedback: 'Excellent project',
        overall_summary: 'Strong candidate'
      )
      expect(evaluation_job.status).to eq('completed')
    end

    it 'transitions from processing to failed' do
      evaluation_job.start_processing!
      evaluation_job.fail!('Processing error')
      expect(evaluation_job.status).to eq('failed')
    end
  end

  describe '#can_retry?' do
    let(:evaluation_job) { create(:evaluation_job, status: 'failed', retry_count: 2) }

    it 'returns true when retries available' do
      expect(evaluation_job.can_retry?).to be true
    end

    it 'returns false when max retries exceeded' do
      evaluation_job.update(retry_count: 3)
      expect(evaluation_job.can_retry?).to be false
    end
  end

  describe '#result' do
    let(:evaluation_job) { create(:evaluation_job, :completed) }

    it 'returns results when completed' do
      results = evaluation_job.result
      expect(results).to be_a(Hash)
      expect(results.keys).to include(:cv_match_rate, :cv_feedback, :project_score)
    end

    it 'returns nil when not completed' do
      incomplete_job = create(:evaluation_job)
      expect(incomplete_job.result).to be_nil
    end
  end
end
