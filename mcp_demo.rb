require 'bundler/setup'

require 'ruby_llm'
require 'ruby_llm/mcp'

RubyLLM.configure do |config|
  config.ollama_api_base = 'http://localhost:11434/v1'
end

client = RubyLLM::MCP::Client.new(
  name: 'user-management-mcp',
  transport_type: :streamable_http,
  config: { url: 'http://localhost:3000/mcp' }
)


chat = RubyLLM.chat(model: 'llama3.1:8b', provider: :ollama, assume_model_exists: true)
chat.with_tools(*client.tools)

response = chat.ask("Create a new user with a random name (via MCP) and then show me the last user.")
puts response.content


