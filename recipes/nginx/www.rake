scope :nginx do
  set_default :www_http_port, 80
  set_default :www_https_port, 443
  set_default :www_paths, {}
end

namespace :nginx do
  namespace :www do
    desc 'Create www config files.'
    task :init do
      template('nginx/www.conf.erb', "#{nginx.etc_dir}/www.conf", true)
      template('nginx/sites-enabled/static.conf.erb', "#{nginx.etc_dir}/sites-enabled/static.http.conf", true) unless nginx.www_paths.empty?
      template('nginx/sites-enabled/php.conf.erb', "#{nginx.etc_dir}/sites-enabled/php.http.conf", true)
    end
    
    [:start, :stop, :reload].each do|t|
      desc "#{t} nginx www instance."
      task t do
        sudo self.send("nginx_#{t}_cmd", :www)
      end
    end
    
    desc 'Restart nginx www instance.'
    task :restart do
      nginx_restart(:www)
    end
  end
end
