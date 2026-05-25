# Compatibility shim for running Middleman 4.3.x on Ruby 3.1+.
# Loaded via RUBYOPT before any gem code runs.
#
# Ruby 3.1+ removed/changed three things this old stack relies on:
#   1. Psych 4.0 safe-load mode rejects Time in YAML frontmatter
#   2. URI.escape was removed in Ruby 3.0
#   (Encoding is handled by the -E flag passed alongside this in RUBYOPT)

require 'yaml'
require 'time'
require 'uri'

# Psych 4.0+ (Ruby 3.1+) defaults YAML.load to safe mode, rejecting Time
# objects. Middleman 4.3.x frontmatter and data files use ISO 8601 timestamps.
module YAMLTimePatch
  def load(yaml, *args, **kwargs)
    kwargs[:permitted_classes] = Array(kwargs[:permitted_classes]) | [::Time, ::Date, ::DateTime, ::Symbol]
    super(yaml, *args, **kwargs)
  end
end
YAML.singleton_class.prepend(YAMLTimePatch)

# URI.escape was removed in Ruby 3.0. Several old gems (sassc, padrino-helpers)
# still call it. Restore the pre-3.0 behaviour using the RFC2396 parser.
unless URI.respond_to?(:escape)
  def URI.escape(str, unsafe = nil)
    str = str.to_s
    unsafe ? URI::RFC2396_Parser.new.escape(str, unsafe) : URI::RFC2396_Parser.new.escape(str)
  end
  URI.singleton_class.alias_method(:encode, :escape)
end
