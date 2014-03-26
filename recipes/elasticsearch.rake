scope :es do
  set_default :plugins_dir,  '/usr/local/var/lib/elasticsearch/plugins'
  set_default :cluster_name, 'default_cluster'
  set_default :data_dir,     ->{ "#{data_dir}/elasticsearch/" }
  set_default :network_host, '127.0.0.1'
  set_default :config_file,  ->{ "#{etc_dir}/elasticsearch/config.yml" }

  #-f can let elasticsearch running in the foreground
  set_default :start, ->{ "elasticsearch -d --config=#{es.config_file} -p #{run_dir}/elasticsearch.pid" }
  #set_default :elasticsearch_stop, ->{"elasticsearch -D es.config=#{es_config} -p #{run_dir}/elasticsearch.pid stop"}
  set_default :stop,  ->{ "kill `cat #{run_dir}/elasticsearch.pid`" }
  set_default :shutdown, ->{ "curl -XPOST 'http://#{es.network_host}:9200/_shutdown'" }
end

namespace :elasticsearch do
  
  desc "Initialize elasticsearch directory and copy it's config files to etc path."
  task :init do  
    mkdir_p("#{etc_dir}/elasticsearch")
    template('elasticsearch/config.yml.erb', es.config_file)
    template('elasticsearch/logging.yml.erb', "#{etc_dir}/elasticsearch/logging.yml")
  end
  
  [:start, :stop, :shutdown].each do|cmd|
    desc "#{cmd} elasticsearch."
    task cmd do     
      run es.send("#{cmd}")
    end
  end
end