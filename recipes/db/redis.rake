set_default :redis_conf, ->{"#{etc_dir}/redis.conf"}
set_default :redis_dir, ->{"#{data_dir}/redis"}
set_default :redis_pid, ->{"#{run_dir}/redis.pid"}
set_default :redis_port, 6379

set_default :redis_start, ->{"redis-server #{redis_conf}"}
set_default :redis_stop, ->{"redis-cli -p #{redis_port} shutdown"}
set_default :redis_restart, ->{"kill -2 `#{redis_pid}` && #{redis_start}"}

set_default :redis_daemonize, "yes"
set_default :redis_timeout, 0
set_default :redis_loglevel, "notice"
set_default :redis_logfile, "stdout"
set_default :redis_databases, 16
set_default :rdbcompression, "yes"
set_default :rdbchecksum, "yes"
set_default :redis_dbfilename, "dump.rdb"
set_default :redis_appendonly, "yes"
set_default :redis_activerehashing, "yes"

namespace :db do
  namespace :redis do
    desc "Initialize redis directory and copy redis.conf to etc directory."
    task :init do
      mkdir_p(redis_dir)
      template("redis.conf.erb", redis_conf)
    end
    
    [:start, :stop, :restart].each do|cmd|
      desc "#{cmd} redis"
      task cmd do     
        run self.send("redis_#{cmd}")
      end
    end
  end
end
