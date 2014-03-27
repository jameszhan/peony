scope :mongo do
  set_default :mongod,      '/usr/local/bin/mongod'
  set_default :master_name, 'master'
  set_default :slave_name,  'slave'

  set_default :master_dir,    ->{ "#{data_dir}/mongo/#{mongo.master_name}" }
  set_default :slave_dir,     ->{ "#{data_dir}/mongo/#{mongo.slave_name}" }
  set_default :etc_dir,       ->{ "#{etc_dir}/mongo" }
  set_default :log_dir,       ->{ "#{log_dir}/mongo" }
  set_default :run_dir,       ->{ "#{run_dir}/mongo" }

  set_default :fork,        true
  set_default :jsonp,       true
  set_default :rest,        true

  set_default :master_port, 27017
  set_default :slave_port,  27018
  set_default :slave_source,  ->{ "127.0.0.1:#{mongo.master_port}" }

  set_default :master_conf,   ->{ "#{mongo.etc_dir}/#{mongo.master_name}.conf" }
  set_default :slave_conf,    ->{ "#{mongo.etc_dir}/#{mongo.slave_name}.conf" }

  set_default :master_start,  ->{ "#{mongo.mongod} --config #{mongo.master_conf}" }
  set_default :slave_start,   ->{ "#{mongo.mongod} --config #{mongo.slave_conf}" }
  set_default :master_stop,   ->{ "kill -2 `cat #{mongo.run_dir}/#{mongo.master_name}.pid`" }
  set_default :slave_stop,    ->{ "kill -2 `cat #{mongo.run_dir}/#{mongo.slave_name}.pid`" }
end


namespace :db do  
  namespace :mongo do
    
    desc 'Create the directory for mongodb, and copy mongo config file to etc directory.'
    task :init do
      mkdir_p(mongo.master_dir, mongo.slave_dir, mongo.etc_dir, mongo.log_dir, mongo.run_dir)
      template('mongo/master.conf.erb', mongo.master_conf, true)
      template('mongo/slave.conf.erb', mongo.slave_conf, true)
    end
    
    [:master, :slave].each do|ns|
      namespace ns do        
        [:start, :stop].each do|t|
          desc "#{t} mongodb #{ns}"
          task t do
            run mongo.send("#{ns}_#{t}")
          end
        end
      end
    end
    
    desc 'Start the master mongodb instance'
    task :start => 'master:start' do
    end
    
    desc 'Stop the master mongodb instance'
    task :stop => 'master:stop' do
    end
  end
end