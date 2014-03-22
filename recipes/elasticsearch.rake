set_default :es_plugins_dir,  '/usr/local/var/lib/elasticsearch/plugins'
set_default :es_cluster_name, 'default_cluster'
set_default :es_data_dir,     ->{ "#{data_dir}/elasticsearch/" }
set_default :es_network_host, '127.0.0.1'
set_default :es_config,       ->{ "#{etc_dir}/elasticsearch/config.yml" }

#-f can let elasticsearch running in the foreground
set_default :elasticsearch_start, ->{ "elasticsearch -D es.config=#{es_config} -p #{run_dir}/elasticsearch.pid" }
#set_default :elasticsearch_stop, ->{"elasticsearch -D es.config=#{es_config} -p #{run_dir}/elasticsearch.pid stop"}
set_default :elasticsearch_stop,  ->{ "kill `cat #{run_dir}/elasticsearch.pid`" }
set_default :elasticsearch_shutdown, ->{ "curl -XPOST 'http://#{es_network_host}:9200/_shutdown'" }

namespace :elasticsearch do
  
  desc "Initialize elasticsearch directory and copy it's config files to etc path."
  task :init do  
    mkdir_p("#{etc_dir}/elasticsearch")
    template('elasticsearch/config.yml.erb', es_config)
    template('elasticsearch/logging.yml.erb', "#{etc_dir}/elasticsearch/logging.yml")
  end
  
  [:start, :stop, :shutdown].each do|cmd|
    desc "#{cmd} elasticsearch."
    task cmd do     
      run self.send("elasticsearch_#{cmd}")
    end
  end
end