set_default :mysql_home, `brew --prefix mysql`.strip
set_default :mysqld, "/usr/local/bin/mysqld_safe"
set_default :mysqladmin, "/usr/local/bin/mysqladmin"

set_default :mysql_dir, ->{"#{data_dir}/mysql"}
set_default :mysql_log_dir, ->{"#{log_dir}/mysql"}

set_default :mysql_user, "root"
set_default :mysql_password, "123456"

set_default :mysql_start, ->{
<<-CMD
#{mysqld} --verbose \
--user=#{user} \
--basedir=#{mysql_home} \
--datadir=#{mysql_dir} \
--tmpdir=/tmp \
--max-allowed-packet=64m \
--log-error=#{mysql_log_dir}/error.log &
CMD
}

set_default :mysql_stop, ->{"#{mysqladmin} --verbose --user=#{mysql_user} --password=#{mysql_password} shutdown"}
set_default :mysql_status, ->{"#{mysqladmin} --verbose status variables"}


namespace :db do
  
  namespace :mysql do
    task :init do
      mkdir_p(mysql_dir, mysql_log_dir)
    end
    task :start do
      run mysql_start
    end    
    task :stop do
      run mysql_stop
    end
    task :status do
      run mysql_status
    end
    namespace :web do
      task :init do
      end
      
      [:start, :reload, :stop].each do|t|
        task t => "nginx:www:#{t}"
      end
    end        
  end
  
end