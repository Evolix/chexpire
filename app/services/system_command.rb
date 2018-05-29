require "null_logger"

class SystemCommand
  attr_reader :program
  attr_reader :args
  attr_reader :logger

  def initialize(program, args, logger: NullLogger.new)
    @program = program
    @args = Array.wrap(args)
    @logger = logger
  end

  def execute
    logger.log :before_command, syscmd

    raw = `syscmd`

    logger.log :after_command, raw

    raw
  end

  def syscmd
    escaped_args = args.map { |arg|
      '"' + escape_arg(arg) + '"'
    }

    [program, escaped_args].join(" ")
  end

  private

  def escape_arg(arg)
    arg.to_s.gsub('"') { '\"' }
  end
end
