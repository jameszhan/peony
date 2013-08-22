set_default :nginx, ->{"/usr/local/bin/nginx"}
set_default :nginx_home,    ->{`brew --prefix nginx`.strip}
set_default :nginx_etc_dir, ->{"#{etc_dir}/nginx"}
set_default :nginx_run_dir, ->{"#{run_dir}/nginx"}
set_default :nginx_prefix, ->{"#{log_dir}/nginx"}

set_default :worker_processes, 8
            
set_default :upstreams, [
  {name: :fastcgi_server, servers: ["127.0.0.1:6666"]}, 
]

set_default :server_name, "localhost"

set_default :use_ssl, false
set_default :ssl_certificate,	    ->{"#{etc_dir}/ssl/server.crt"}	  
set_default :ssl_certificate_key, ->{"#{etc_dir}/ssl/server.key"}


def nginx_start_cmd(name)
  "#{nginx} -c #{nginx_etc_dir}/#{name}.conf -p #{nginx_prefix}"
end

def nginx_stop_cmd(name)
  "#{nginx} -s quit -c #{nginx_etc_dir}/#{name}.conf -p #{nginx_prefix}"
end

def nginx_reload_cmd(name)
  "#{nginx} -s reload -c #{nginx_etc_dir}/#{name}.conf -p #{nginx_prefix}"
end

def nginx_restart(name)
  invoke "nginx:#{name}:stop"
  puts "Start nginx......"
  sleep 5
  invoke "nginx:#{name}:start"
end

namespace :nginx do
  task :init do
    mkdir_p(nginx_etc_dir, nginx_run_dir, nginx_prefix)
    unless File.exists?("#{nginx_etc_dir}/conf")
      FileUtils.cp_r(find_templates("nginx/conf", false).first, nginx_etc_dir)
    end
    FileUtils.mkdir_p("#{nginx_etc_dir}/sites-enabled") unless File.exists?("#{nginx_etc_dir}/sites-enabled")
  end
end
