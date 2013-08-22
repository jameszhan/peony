set_default :mysql_home, `brew --prefix mysql`.strip
set_default :mysqld, "/usr/local/bin/mysqld_safe"
set_default :mysqladmin, "/usr/local/bin/mysqladmin"
set_default :mysql_install_db, "/usr/local/bin/mysql_install_db"

set_default :mysql_dir, ->{"#{data_dir}/mysql/#{mysql_port}"}
set_default :mysql_log_dir, ->{"#{log_dir}/mysql/#{mysql_port}"}
set_default :mysql_conf, ->{"#{etc_dir}/my.cnf"}

set_default :mysql_user, "root"
set_default :mysql_password, "123456"

set_default :mysql_pid_file, ->{"#{run_dir}/mysql/#{mysql_port}.pid"}
set_default :mysql_port, '3306'
set_default :mysql_socket, "/tmp/mysql.sock"
set_default :mysql_charset, 'UTF8'
set_default :mysql_general_log, 'ON'
set_default :mysql_slow_query_log, 'ON'

set_default :mysql_start, ->{"#{mysqld}  --defaults-file=#{mysql_conf} --datadir=#{mysql_dir} --basedir=#{mysql_home} &"}
set_default :mysql_stop, ->{"#{mysqladmin} --verbose --user=#{mysql_user} --password=#{mysql_password} shutdown"}
set_default :mysql_status, ->{"#{mysqladmin} --verbose status variables"}

namespace :db do
  
  namespace :mysql do
    
    desc "Create mysql directorys, config file and run mysql_install_db"
    task :init do
      mkdir_p(mysql_dir, mysql_log_dir, "#{run_dir}/mysql/")
      template("mysql/my.cnf.erb", mysql_conf, true)
      run "#{mysql_install_db} --defaults-file=#{mysql_conf} --datadir=#{mysql_dir} --basedir=#{mysql_home}" if Dir["#{mysql_dir}/*"].empty?
    end
    
    [:start, :stop, :status].each do|t|
      desc "#{t} mysql instance."
      task t do
        run self.send("mysql_#{t}")
      end
    end
    
    desc "Set mysql root user password."
    task :set_root_pass do
      run "mysqladmin --no-defaults --port=#{mysql_port} --user=root --protocol=tcp password '#{mysql_password}'"
    end
    
    namespace :web do
      [:start, :stop].each do|t|
        desc "#{t} phpMyAdmin, please put the phpMyAdmin to #{www_dir}"
        task t => ["nginx:www:#{t}", "php:fcgi:#{t}"]
      end
    end        
  end
  
end