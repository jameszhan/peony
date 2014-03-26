scope :mysql do
  set_default :home,              `brew --prefix mysql`.strip
  set_default :mysqld,            '/usr/local/bin/mysqld_safe'
  set_default :mysqladmin,        '/usr/local/bin/mysqladmin'
  set_default :mysql_install_db,  '/usr/local/bin/mysql_install_db'

  set_default :data_dir,          ->{ "#{data_dir}/mysql/#{mysql_port}" }
  set_default :log_dir,           ->{ "#{log_dir}/mysql/#{mysql_port}" }
  set_default :config_file,       ->{ "#{etc_dir}/my.cnf" }

  set_default :user,              'root'
  set_default :password,          '123456'

  set_default :pid_file,          ->{ "#{run_dir}/mysql/#{mysql.port}.pid" }
  set_default :port,              '3306'
  set_default :socket,            '/tmp/mysql.sock'
  set_default :charset,           'UTF8'
  set_default :general_log,       'ON'
  set_default :slow_query_log,    'ON'

  set_default :start,       ->{ "#{mysql.mysqld}  --defaults-file=#{mysql.config_file} --datadir=#{mysql.data_dir} --basedir=#{mysql.home} &" }
  set_default :stop,        ->{ "#{mysql.mysqladmin} --verbose --user=#{mysql.user} --password=#{mysql.password} shutdown" }
  set_default :status,      ->{ "#{mysql.mysqladmin} --verbose status variables" }
end

namespace :db do
  namespace :mysql do
    desc 'Create mysql directorys, config file and run mysql_install_db'
    task :init do
      mkdir_p(mysql.data_dir, mysql.log_dir, "#{run_dir}/mysql/")
      template('mysql/my.cnf.erb', mysql.config_file, true)
      run "#{mysql.mysql_install_db} --defaults-file=#{mysql.config_file} --datadir=#{mysql.data_dir} --basedir=#{mysql.home}" if Dir["#{mysql.data_dir}/*"].empty?
    end
    
    [:start, :stop, :status].each do|t|
      desc "#{t} mysql instance."
      task t do
        run mysql.send(t)
      end
    end
    
    desc 'Set mysql root user password.'
    task :set_root_pass do
      run "#{mysql.mysqladmin} --no-defaults --port=#{mysql.port} --user=root --protocol=tcp password '#{mysql.password}'"
    end
    
    namespace :web do
      [:start, :stop].each do|t|
        desc "#{t} phpMyAdmin, please put the phpMyAdmin to #{www_dir}"
        task t => ["nginx:www:#{t}", "php:fcgi:#{t}"]
      end
    end        
  end
  
end