class LlmService
  class LlmError < StandardError; end
  class RateLimitError < LlmError; end
  class TimeoutError < LlmError; end

  def initialize
    @client = setup_client
    @max_retries = 3
    @base_delay = 1
  end

  def chat_completion(prompt, temperature: 0.3, max_tokens: 2000)
    with_retry do
      response = @client.post('/v1/chat/completions') do |req|
        req.headers['Authorization'] = "Bearer #{api_key}"
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          model: model_name,
          messages: [{ role: 'user', content: prompt }],
          temperature: temperature,
          max_tokens: max_tokens
        }.to_json
      end

      handle_response(response)
    end
  end

  def generate_embedding(text)
    with_retry do
      response = @client.post('/v1/embeddings') do |req|
        req.headers['Authorization'] = "Bearer #{api_key}"
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          model: embedding_model,
          input: text
        }.to_json
      end

      result = handle_response(response)
      result.dig('data', 0, 'embedding')
    end
  end

  private

  def setup_client
    Faraday.new(url: base_url) do |f|
      f.request :timeout, open: 30, read: 60
      f.adapter Faraday.default_adapter
    end
  end

  def with_retry
    retries = 0
    begin
      yield
    rescue RateLimitError => e
      retries += 1
      if retries <= @max_retries
        delay = @base_delay * (2 ** (retries - 1))
        Rails.logger.warn "Rate limited, retrying in #{delay} seconds (attempt #{retries}/#{@max_retries})"
        sleep(delay)
        retry
      else
        raise e
      end
    rescue TimeoutError => e
      retries += 1
      if retries <= @max_retries
        delay = @base_delay * retries
        Rails.logger.warn "Request timeout, retrying in #{delay} seconds (attempt #{retries}/#{@max_retries})"
        sleep(delay)
        retry
      else
        raise e
      end
    end
  end

  def handle_response(response)
    case response.status
    when 200
      JSON.parse(response.body)
    when 429
      raise RateLimitError, 'Rate limit exceeded'
    when 408, 504
      raise TimeoutError, 'Request timeout'
    else
      error_body = JSON.parse(response.body) rescue { 'error' => 'Unknown error' }
      raise LlmError, "API error: #{response.status} - #{error_body['error']}"
    end
  end

  def api_key
    ENV['OPENAI_API_KEY'] || ENV['LLM_API_KEY'] || 'mock-api-key'
  end

  def base_url
    ENV['LLM_BASE_URL'] || 'https://api.openai.com'
  end

  def model_name
    ENV['LLM_MODEL'] || 'gpt-4'
  end

  def embedding_model
    ENV['EMBEDDING_MODEL'] || 'text-embedding-ada-002'
  end
end