set_default :httpd, "/usr/sbin/httpd"
set_default :httpd_server_root, "/usr"
set_default :httpd_share_dir, "/usr/share/httpd"

set_default :httpd_etc_dir, ->{"#{etc_dir}/httpd"}
set_default :httpd_conf, ->{"#{httpd_etc_dir}/httpd.conf"}

set_default :httpd_log_dir, ->{"#{log_dir}/httpd"}
set_default :webdav_dir, ->{"#{var_dir}/webdav"}
set_default :auth_user_file, ->{"#{httpd_etc_dir}/user.passwd"}
set_default :httpd_server_admin, "zhiqiangzhan@gmail.com"
set_default :httpd_port, 8888
set_default :httpd_server_name, ->{"localhost:#{httpd_port}"}

set_default :auth_user, "admin"

namespace :httpd do 
  task :init do
    search_paths.each do|sp|
      mkdir_p(httpd_etc_dir, "#{httpd_etc_dir}/extra", httpd_log_dir, webdav_dir)
      Dir["#{sp}/httpd/**/*.erb"].each do|fn|
        target = fn.sub("#{sp}/httpd", "#{httpd_etc_dir}").sub(/.erb$/, "")
        template(fn, target) unless File.exists?(target)
      end
    end
  end 
  
  task :auth_user_file do
    run "htpasswd -c #{auth_user_file} #{auth_user}"
  end
  
  namespace :webdav do
    [:start, :restart, :stop].each do|t|
      task t do
        run "#{httpd} -f #{httpd_conf} -k #{t}"
      end
    end
  end
end