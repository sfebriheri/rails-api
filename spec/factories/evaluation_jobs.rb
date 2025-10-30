FactoryBot.define do
  factory :evaluation_job do
    job_id { SecureRandom.uuid }
    job_title { Faker::Job.title }
    status { 'queued' }
    retry_count { 0 }
    cv_document { association :document, document_type: 'cv' }
    project_document { association :document, document_type: 'project_report' }
    user { association :user }

    trait :processing do
      status { 'processing' }
      started_at { Time.current }
    end

    trait :completed do
      status { 'completed' }
      completed_at { Time.current }
      cv_match_rate { 0.85 }
      cv_feedback { 'Good match for the position' }
      project_score { 4.5 }
      project_feedback { 'Strong technical implementation' }
      overall_summary { 'Recommended for interview' }
    end

    trait :failed do
      status { 'failed' }
      completed_at { Time.current }
      error_message { 'Processing failed' }
    end
  end
end
