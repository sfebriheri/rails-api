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
    key = ENV['OPENAI_API_KEY'] || ENV['LLM_API_KEY']

    if key.blank?
      raise LlmError, 'LLM API key not configured. Set OPENAI_API_KEY or LLM_API_KEY environment variable.'
    end

    if Rails.env.production? && key.length < 20
      raise LlmError, 'Invalid API key format. Please check your LLM_API_KEY configuration.'
    end

    key
  end

  def base_url
    url = ENV['LLM_BASE_URL'] || 'https://api.openai.com'

    unless url.start_with?('http://', 'https://')
      raise LlmError, 'Invalid LLM_BASE_URL. Must start with http:// or https://'
    end

    url
  end

  def model_name
    model = ENV['LLM_MODEL']

    if model.blank?
      raise LlmError, 'LLM model not configured. Set LLM_MODEL environment variable.'
    end

    model
  end

  def embedding_model
    model = ENV['EMBEDDING_MODEL']

    if model.blank?
      raise LlmError, 'Embedding model not configured. Set EMBEDDING_MODEL environment variable.'
    end

    model
  end
end
