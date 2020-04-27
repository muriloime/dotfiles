require 'pp'

Pry.editor = 'code'
Pry.config.color = true
Pry.config.theme = 'solarized'


# === COLORS ===
unless ENV['PRY_BW']
  Pry.color = true
  Pry.config.theme = 'railscasts'
  # Pry.config.prompt = PryRails::RAILS_PROMPT if defined?(PryRails::RAILS_PROMPT)
  # Pry.config.prompt ||= Pry.prompt
end

color_escape_codes = {
  black: "\033[0;30m",
  red: "\033[0;31m",
  green: "\033[0;32m",
  yellow: "\033[0;33m",
  blue: "\033[0;34m",
  purple: "\033[0;35m",
  cyan: "\033[0;36m",
  reset: "\033[0;0m"
}

env_colors = {
  'development' => color_escape_codes[:yellow],
  'test' => color_escape_codes[:purple],
  'staging' => color_escape_codes[:purple],
  'production' => color_escape_codes[:red]
}

if defined? Rails
  Pry.config.prompt = proc do |obj, nest_level, _|
    color = env_colors.fetch(Rails.env, color_escape_codes[:reset])
    colored_environment_name = "#{color}#{Rails.env}#{color_escape_codes[:reset]}"
    "(#{colored_environment_name}) #{obj}:#{nest_level}> "
  end
end

eval(File.open('.irbrc').read) if File.exist?('.irbrc')
