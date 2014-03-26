scope :nginx do
  set_default :bin,     ->{ '/usr/local/bin/nginx' }
  set_default :home,    ->{ `brew --prefix nginx`.strip }
  set_default :etc_dir, ->{ "#{etc_dir}/nginx" }
  set_default :run_dir, ->{ "#{run_dir}/nginx" }
  set_default :prefix,  ->{ "#{log_dir}/nginx" }

  set_default :worker_processes, 8

  set_default :upstreams, [
      {name: :fastcgi_server, servers: ['127.0.0.1:6666']},
      {name: :catalina_server, servers: ['127.0.0.1:8080']}
  ]

  set_default :server_name, 'localhost'

  set_default :use_ssl,     true
  set_default :ssl_certificate,	    ->{"#{etc_dir}/ssl/server.crt"}
  set_default :ssl_certificate_key, ->{"#{etc_dir}/ssl/server.key"}
end

def nginx_start_cmd(name)
  "#{nginx.bin} -c #{nginx.etc_dir}/#{name}.conf -p #{nginx.prefix}"
end

def nginx_stop_cmd(name)
  "#{nginx.bin} -s quit -c #{nginx.etc_dir}/#{name}.conf -p #{nginx.prefix}"
end

def nginx_reload_cmd(name)
  "#{nginx.bin} -s reload -c #{nginx.etc_dir}/#{name}.conf -p #{nginx.prefix}"
end

def nginx_restart(name)
  say_status :restart, 'restart nginx', :green
  invoke "nginx:#{name}:stop"
  say 'Start nginx......', :yellow
  sleep 5
  invoke "nginx:#{name}:start"
end

namespace :nginx do
  desc "Initialize nginx directory and create it's config files."
  task :init do
    mkdir_p(nginx.etc_dir, nginx.run_dir, nginx.prefix)
    unless File.exists?("#{nginx.etc_dir}/conf")
      FileUtils.cp_r(find_templates("nginx/conf", false).first, nginx.etc_dir)
    end
    FileUtils.mkdir_p("#{nginx.etc_dir}/sites-enabled") unless File.exists?("#{nginx.etc_dir}/sites-enabled")
  end
end
