scope :redis do
  set_default :config_file,       ->{ "#{etc_dir}/redis.conf" }
  set_default :data_dir,          ->{ "#{data_dir}/redis" }
  set_default :pid_file,          ->{ "#{run_dir}/redis.pid" }
  set_default :port,              6379

  set_default :start,             ->{ "redis-server #{redis.config_file}" }
  set_default :stop,              ->{ "redis-cli -p #{redis.port} shutdown" }
  set_default :restart,           ->{ "kill -2 `#{redis.pid_file}` && #{redis.start}" }

  set_default :daemonize,         'yes'
  set_default :timeout,           0
  set_default :loglevel,          'notice'
  set_default :logfile,           'stdout'
  set_default :databases,         16
  set_default :rdbcompression,    'yes'
  set_default :rdbchecksum,       'yes'
  set_default :dbfilename,        'dump.rdb'
  set_default :appendonly,        'yes'
  set_default :activerehashing,   'yes'
end

namespace :db do
  namespace :redis do
    desc 'Initialize redis directory and copy redis.conf to etc directory.'
    task :init do
      mkdir_p(redis.data_dir)
      template('redis.conf.erb', redis.config_file)
    end
    
    [:start, :stop, :restart].each do|cmd|
      desc "#{cmd} redis"
      task cmd do     
        run redis.send(cmd)
      end
    end
  end
end
