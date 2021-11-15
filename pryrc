require 'pp'

Pry.editor = 'code'
Pry.config.color = true
Pry.config.theme = 'solarized'

if defined?(PryByebug)
  Pry.commands.alias_command 'cc', 'continue'
  Pry.commands.alias_command 'ss', 'step'
  Pry.commands.alias_command 'nn', 'next'
  Pry.commands.alias_command 'ff', 'finish'
end

Pry.commands.alias_command 'ee', 'exit'
# Pry.commands.alias_command 'e!', 'exit!'
Pry.commands.alias_command 'dd', 'disable-pry' rescue nil
Pry.commands.alias_command "hh", "hist -T 20", desc: "Last 20 commands"
Pry.commands.alias_command "hg", "hist -T 20 -G", desc: "Up to 20 commands matching expression"
Pry.commands.alias_command "hG", "hist -G", desc: "Commands matching expression ever used"
Pry.commands.alias_command "hr", "hist -r", desc: "hist -r <command number> to run a command"


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



# begin
#   require 'awesome_print'
#   AwesomePrint.pry!
# rescue LoadError
#   warn "awesome_print not installed"
# end

Pry::Commands.block_command('enable-pry', 'Enable `binding.pry` feature') do
  ENV['DISABLE_PRY'] = nil
end

def rr
  reload!
end

class Object
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end