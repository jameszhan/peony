set_default :es_plugins_dir, "/usr/local/var/lib/elasticsearch/plugins"
set_default :es_cluster_name, "default_cluster"
set_default :es_data_dir, ->{"#{data_dir}/elasticsearch/"}
set_default :es_network_host, "127.0.0.1"
set_default :es_config, ->{"#{etc_dir}/elasticsearch/config.yml"}

#-f can let elasticsearch running in the foreground
set_default :elasticsearch_start, ->{"elasticsearch -D es.config=#{es_config} -p #{run_dir}/elasticsearch.pid"}
#set_default :elasticsearch_stop, ->{"elasticsearch -D es.config=#{es_config} -p #{run_dir}/elasticsearch.pid stop"}
set_default :elasticsearch_stop, ->{"kill `cat #{run_dir}/elasticsearch.pid`"}
set_default :elasticsearch_shutdown, ->{"curl -XPOST 'http://#{es_network_host}:9200/_shutdown'"}

namespace :elasticsearch do
  
  task :init do
    ["#{etc_dir}/elasticsearch"].each do|dir|
      FileUtils.mkdir_p(dir) unless File.exists?(dir)
      fail "#{dir} must be a directory!" unless File.directory?(dir)
    end       
    template("elasticsearch/config.yml.erb", es_config)
    template("elasticsearch/logging.yml.erb", "#{etc_dir}/elasticsearch/logging.yml")
  end
  
  [:start, :stop, :shutdown].each do|cmd|
    task cmd do     
      sh self.send("elasticsearch_#{cmd}") do|res, stat|
        puts stat.inspect if !res
      end
    end
  end
end