set_default :www_http_port, 80
set_default :www_https_port, 443
set_default :www_paths, {}

namespace :nginx do
  namespace :www do
    task :init do
      template("nginx/www.conf.erb", "#{nginx_etc_dir}/www.conf", true)
      template("nginx/sites-enabled/static.conf.erb", "#{nginx_etc_dir}/sites-enabled/static.http.conf", true) unless www_paths.empty?
    end
    
    [:start, :stop, :reload].each do|t|
      task t do
        sudo self.send("nginx_#{t}_cmd", :www) do|res, stat|
          puts stat.inspect if !res
        end
      end
    end
    
    task :restart do
      nginx_restart(:www)
    end
  end
end
