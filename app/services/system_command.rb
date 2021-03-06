# Copyright (C) 2018 Colin Darie <colin@darie.eu>, 2018 Evolix <info@evolix.fr>
# License: GNU AGPL-3+ (see full text in LICENSE file)

class SystemCommand
  Result = Struct.new(:command, :exit_status, :stdout, :stderr)
  class NotAllowedError < StandardError; end

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

    result = call(syscmd)

    logger.log :after_command, result

    result
  end

  def syscmd
    escaped_args = args.map { |arg|
      '"' + escape_arg(arg) + '"'
    }

    [program, escaped_args].join(" ")
  end

  private

  # :nocov:
  def call(cmd)
    pid, _, stdout, stderr = Open4.popen4 cmd
    _, status = Process.waitpid2 pid

    Result.new(
      syscmd,
      status.exitstatus || 255,
      stdout.read.strip,
      stderr.read.strip,
    )
  end
  # :nocov:

  def escape_arg(arg)
    arg.to_s.gsub('"') { '\"' }
  end
end
