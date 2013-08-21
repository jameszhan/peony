set_default :mongod, "/usr/local/bin/mongod"

set_default :mongo_master_name, "master"
set_default :mongo_slave_name, "slave"

set_default :mongo_master_dir, ->{"#{data_dir}/mongo/#{mongo_master_name}"}
set_default :mongo_slave_dir, ->{"#{data_dir}/mongo/#{mongo_slave_name}"}
set_default :mongo_etc_dir, ->{"#{etc_dir}/mongo"}
set_default :mongo_log_dir, ->{"#{log_dir}/mongo"}
set_default :mongo_run_dir, ->{"#{run_dir}/mongo"}


set_default :mongo_fork , true
set_default :mongo_jsonp, true
set_default :mongo_rest , true

set_default :mongo_master_port, 27017
set_default :mongo_slave_port, 27018
set_default :mongo_slave_source, ->{"127.0.0.1:#{mongo_master_port}"}
                                                       
set_default :mongo_master_conf, ->{"#{mongo_etc_dir}/#{mongo_master_name}.conf"}
set_default :mongo_slave_conf, ->{"#{mongo_etc_dir}/#{mongo_slave_name}.conf"}

set_default :mongo_master_start, ->{"#{mongod} --config #{mongo_master_conf}"}
set_default :mongo_slave_start, ->{"#{mongod} --config #{mongo_slave_conf}"}
set_default :mongo_master_stop, ->{"kill -2 `cat #{mongo_run_dir}/#{mongo_master_name}.pid`"}
set_default :mongo_slave_stop, ->{"kill -2 `cat #{mongo_run_dir}/#{mongo_slave_name}.pid`"}


namespace :db do  
  namespace :mongo do
    task :init do
      mkdir_p(mongo_master_dir, mongo_slave_dir, mongo_etc_dir, mongo_log_dir, mongo_run_dir)
      template("mongo/master.conf.erb", mongo_master_conf, true)
      template("mongo/slave.conf.erb", mongo_slave_conf, true)
    end
    [:master, :slave].each do|ns|
      namespace ns do
        [:start, :stop].each do|t|
          task t do
            run self.send("mongo_#{ns}_#{t}")
          end
        end
      end
    end
    
    task :start => "master:start" do
    end
    
    task :stop => "master:stop" do
    end
  end
end