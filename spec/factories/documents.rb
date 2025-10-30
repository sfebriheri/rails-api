FactoryBot.define do
  factory :document do
    filename { "test_document_#{SecureRandom.hex(4)}.pdf" }
    content_type { 'application/pdf' }
    file_size { 50000 }
    file_path { "/storage/uploads/#{SecureRandom.uuid}.pdf" }
    document_type { 'cv' }
    checksum { Digest::SHA256.hexdigest(SecureRandom.random_bytes(100)) }
    processed { false }
    user { association :user }

    trait :processed do
      processed { true }
      processed_at { Time.current }
      extracted_text { "Sample extracted text from PDF file" }
    end

    trait :cv do
      document_type { 'cv' }
    end

    trait :project_report do
      document_type { 'project_report' }
    end

    trait :job_description do
      document_type { 'job_description' }
    end

    trait :case_study do
      document_type { 'case_study' }
    end

    trait :scoring_rubric do
      document_type { 'scoring_rubric' }
    end
  end
end
