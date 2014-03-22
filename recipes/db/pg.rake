set_default :pg_home,     ->{ `brew --prefix postgresql`.strip }
set_default :pg_initdb,   '/usr/local/bin/initdb'
set_default :pg_ctl,      '/usr/local/bin/pg_ctl'

set_default :pg_data_dir,   ->{ "#{data_dir}/pgsql" }
set_default :pg_init,       ->{ "#{pg_initdb} -D #{pg_data_dir} --debug" }
set_default :pg_start,      ->{ "#{pg_ctl} -D #{pg_data_dir} -l #{log_dir}/pgsql.log start" }
set_default :pg_stop,       ->{ "#{pg_ctl} -D #{pg_data_dir} stop" }
set_default :pg_reload,     ->{ "#{pg_ctl} -D #{pg_data_dir} reload" }
set_default :pg_restart,    ->{ "#{pg_ctl} -D #{pg_data_dir} -l #{log_dir}/pgsql.log restart" }

set_default :pg_super_users, {
  pgsql: '123456'
}

namespace :db do
  namespace :pg do
    
    desc 'Execute postgres initdb.'
    task :init do
      if File.exists?("#{pg_data_dir}/postgresql.conf")
        puts 'Postgresql database has already initialized.'
      else
        run pg_init
      end
    end
    
    desc 'Set super users for postgresql.'
    task :set_super_users do
      pg_super_users.each do|user, password|
        sqls = ["CREATE USER #{user} WITH PASSWORD '#{password}';", "ALTER USER #{user} WITH SUPERUSER;"]
        sqls.each do|sql|
          run "psql -d postgres -c \"#{sql}\""
        end        
      end
    end
    
    [:start, :stop, :restart, :reload].each do|cmd|
      desc "#{cmd} postgresql instance."
      task cmd do
        run self.send("pg_#{cmd}")
      end
    end
  end
end