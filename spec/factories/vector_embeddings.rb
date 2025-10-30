FactoryBot.define do
  factory :vector_embedding do
    document { association :document }
    content_chunk { Faker::Lorem.paragraph }
    embedding_vector { Array.new(1536) { rand(-1.0..1.0) } }
    chunk_index { 0 }
    metadata { {} }
  end
end
