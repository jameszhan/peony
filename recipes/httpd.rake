scope :httpd do
  set_default :bin,                 '/usr/sbin/httpd'
  set_default :server_root,         '/usr'
  set_default :share_dir,           '/usr/share/httpd'

  set_default :etc_dir,             ->{ "#{etc_dir}/httpd" }
  set_default :config_file,           ->{ "#{httpd.etc_dir}/httpd.conf" }

  set_default :log_dir,             ->{ "#{log_dir}/httpd" }
  set_default :webdav_dir,          ->{ "#{var_dir}/webdav" }
  set_default :auth_user_file,      ->{ "#{httpd.etc_dir}/user.passwd" }
  set_default :server_admin,        'zhiqiangzhan@gmail.com'
  set_default :port,                6789
  set_default :server_name,         ->{ "localhost:#{httpd.port}" }

  set_default :auth_user,           'admin'
end

namespace :httpd do 
  desc 'Initialize httpd config files.'
  task :init do
    mkdir_p(httpd.etc_dir, "#{httpd.etc_dir}/extra", httpd.log_dir, httpd.webdav_dir)
    template_paths.each do|tp|
      Dir["#{tp}/httpd/**/*.erb"].each do|fn|
        target = fn.sub("#{tp}/httpd", "#{httpd.etc_dir}").sub(/.erb$/, '')
        template(fn, target) unless File.exists?(target)
      end
    end
  end 
  
  desc 'Create AuthUserFile.'
  task :auth_user_file do
    run "htpasswd -c #{httpd.auth_user_file} #{httpd.auth_user}"
  end
  
  namespace :webdav do
    [:start, :restart, :stop].each do|t|
      desc "#{t} httpd instance."
      task t do
        run "#{httpd.bin} -f #{httpd.config_file} -k #{t}"
      end
    end
  end
end