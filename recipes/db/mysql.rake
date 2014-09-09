scope :mysql do
  set_default :home,              `brew --prefix mysql`.strip
  set_default :server,            '/usr/local/bin/mysql.server'
  set_default :mysqld,            '/usr/local/bin/mysqld_safe'
  set_default :mysqladmin,        '/usr/local/bin/mysqladmin'
  set_default :mysql_install_db,  '/usr/local/bin/mysql_install_db'

  set_default :data_dir,          ->{ "#{data_dir}/mysql/#{mysql.port}" }
  set_default :log_dir,           ->{ "#{log_dir}/mysql/#{mysql.port}" }
  set_default :config_file,       ->{ '/etc/my.cnf' }

  set_default :log_error,         ->{ "#{mysql.log_dir}/error.log" }

  set_default :user,              'root'
  set_default :password,          '123456'

  set_default :pid_file,          ->{ "#{run_dir}/mysql/#{mysql.port}.pid" }
  set_default :port,              '3306'
  set_default :socket,            '/tmp/mysql.sock'
  set_default :charset,           'UTF8'
  set_default :general_log,       'ON'
  set_default :slow_query_log,    'ON'

  set_default :run_cmd,      ->{ ->(cmd){"#{mysql.server} #{cmd} --basedir=#{mysql.home} --datadir=#{mysql.data_dir} --pid-file=#{mysql.pid_file} --user=#{user}"} }

  #set_default :start,         ->{ "#{mysql.mysqld}  --defaults-file=#{mysql.config_file} --datadir=#{mysql.data_dir} --basedir=#{mysql.home} &" }
  #set_default :stop,        ->{ "#{mysql.mysqladmin} --verbose --user=#{mysql.user} --password=#{mysql.password} shutdown" }
  #set_default :status,      ->{ "#{mysql.mysqladmin} --verbose status variables" }
end

namespace :db do
  namespace :mysql do
    desc 'Create mysql directorys, config file and run mysql_install_db'
    task :init do
      mkdir_p(mysql.data_dir, mysql.log_dir, "#{run_dir}/mysql/")
      template('mysql/my.cnf.erb', mysql.config_file, true)
      inside mysql.home do
        unless File.exist? "#{mysql.data_dir}/mysql/user.frm"
          ENV['TMPDIR'] = nil
          run "#{mysql.mysql_install_db} --verbose --user=#{mysql.user} --basedir=#{mysql.home} --datadir=#{mysql.data_dir} --tmpdir=/tmp"
        end
        #run "#{mysql.mysql_install_db} --defaults-file=#{mysql.config_file} --datadir=#{mysql.data_dir} --basedir=#{mysql.home}" if Dir["#{mysql.data_dir}/*"].empty?
      end
    end

    [:start, :stop, :restart, :reload, :'force-reload', :status].each do|t|
      desc "#{t} mysql instance."
      task t do
        run mysql.run_cmd.call(t)
      end
    end

=begin
    [:start].each do|t|
      desc "#{t} mysql instance."
      task t do
        run mysql.send(t)
      end
    end
=end

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