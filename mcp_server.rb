#!/usr/bin/env ruby
require 'json'
require 'sinatra/base'
require 'sqlite3'
require 'securerandom'
require_relative 'db'

class MCPServer < Sinatra::Base
  set :port, 3000
  set :bind, '0.0.0.0'

  DB_FILE = 'users.db'

  TOOLS = [
    {
      'name' => 'get_last_user',
      'description' => 'Gets the last user created in the database',
      'inputSchema' => {
        'type' => 'object',
        'properties' => {},
        'required' => []
      }
    },
    {
      'name' => 'create_user',
      'description' => 'Creates a new user in the database',
      'inputSchema' => {
        'type' => 'object',
        'properties' => {
          'name' => {
            'type' => 'string',
            'description' => 'The name of the user'
          }
        },
        'required' => ['name']
      }
    }
  ].freeze

  def rpc_result(id, result)
    content_type 'application/json'
    { 'jsonrpc' => '2.0', 'id' => id, 'result' => result }.to_json
  end

  def rpc_error(id, code, message)
    content_type 'application/json'
    status 400
    { 'jsonrpc' => '2.0', 'id' => id, 'error' => { 'code' => code, 'message' => message } }.to_json
  end

  post '/mcp' do
    json_body = JSON.parse(request.body.read)
    id = json_body['id']
    method = json_body['method']
    params = json_body['params']

    if method.to_s.start_with?('notifications/')
      puts "Received notification: #{method}"
      return rpc_result(id, {}) 
    end

    case method
    when 'initialize'
      puts "MCP Client initialized"
      rpc_result(id, {
        'protocolVersion' => '2024-11-05',
        'capabilities' => { 'tools' => {} },
        'serverInfo' => { 'name' => 'user-management-server', 'version' => '1.0.0' }
      })
    when 'tools/list'
      puts "MCP Client requested tool list"
      rpc_result(id, 'tools' => TOOLS)
    when 'tools/call'
      tool_name = params['name']
      arguments = params['arguments']
      rpc_result(id, execute_tool(tool_name, arguments))
    end
  end

  private

  def execute_tool(tool_name, arguments)
    case tool_name
    when 'get_last_user'
      db = SQLite3::Database.new(DB_FILE)
      db.results_as_hash = true
      user = db.execute('SELECT * FROM users ORDER BY id DESC LIMIT 1')[0]
      db.close
      {
        'content' => [
          {
            'type' => 'text',
            'text' => user.to_json
          }
        ]
      }
    when 'create_user'
      name = arguments['name']
      db = SQLite3::Database.new(DB_FILE)
      db.execute('INSERT INTO users (name) VALUES (?)', [name])
      user_id = db.last_insert_row_id
      db.results_as_hash = true
      user = db.execute('SELECT * FROM users WHERE id = ?', [user_id])[0]
      db.close
      {
        'content' => [
          {
            'type' => 'text',
            'text' => user.to_json
          }
        ]
      }
    end
  end

  run! if app_file == $0
end
