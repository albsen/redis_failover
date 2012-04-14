module RedisFailover
  # Parses server command-line arguments.
  class CLI
    def self.parse(source)
      return {} if source.empty?

      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: redis_failover_server [OPTIONS]"

        opts.on('-P', '--port port', 'Server port') do |port|
          options[:port] = Integer(port)
        end

        opts.on('-p', '--password password', 'Redis password') do |password|
          options[:password] = password.strip
        end

        opts.on('-n', '--nodes nodes', 'Comma-separated redis host:port pairs') do |nodes|
          # turns 'host1:port,host2:port' => [{:host => host, :port => port}, ...]
          options[:nodes] = nodes.split(',').map do |node|
            Hash[[:host, :port].zip(node.strip.split(':'))]
          end
        end

        opts.on('--max-failures count',
          'Max failures before server marks node unavailable (default 3)') do |max|
          options[:max_failures] = Integer(max)
        end

        opts.on('-h', '--help', 'Display all options') do
          puts opts
          exit
        end
      end

      parser.parse(source)

      # assume password is same for all redis nodes
      if password = options[:password]
        options[:nodes].each { |opts| opts.update(:password => password) }
      end

      options
    end
  end
end