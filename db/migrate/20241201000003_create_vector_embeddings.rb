class CreateVectorEmbeddings < ActiveRecord::Migration[7.1]
  def change
    create_table :vector_embeddings do |t|
      t.references :document, null: false, foreign_key: true
      t.text :content_chunk, null: false
      t.json :embedding_vector, null: false
      t.integer :chunk_index, null: false
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :vector_embeddings, [:document_id, :chunk_index], unique: true
  end
end