scope :pg do
  set_default :home,        ->{ `brew --prefix postgresql`.strip }
  set_default :initdb,      '/usr/local/bin/initdb'
  set_default :pg_ctl,      '/usr/local/bin/pg_ctl'

  set_default :data_dir,    ->{ "#{data_dir}/pgsql" }
  set_default :run_cmd,     ->{ lambda{|cmd| "#{pg.pg_ctl} #{cmd} -D #{pg.data_dir} -l #{log_dir}/pgsql.log" }}
  set_default :init,        ->{ "#{pg.pg_ctl} -D #{pg.data_dir} --debug init" }
  #set_default :start,       ->{ "#{pg.pg_ctl} -D #{pg.data_dir} -l #{log_dir}/pgsql.log start" }
  #set_default :stop,        ->{ "#{pg.pg_ctl} -D #{pg.data_dir} stop" }
  #set_default :reload,      ->{ "#{pg.pg_ctl} -D #{pg.data_dir} reload" }
  #set_default :restart,     ->{ "#{pg.pg_ctl} -D #{pg.data_dir} -l #{log_dir}/pgsql.log restart" }

  set_default :super_users, {
      pgsql: '123456'
  }
end

namespace :db do
  namespace :pg do
    
    desc 'Execute postgres initdb.'
    task :init do
      if File.exists?("#{pg.data_dir}/postgresql.conf")
        say 'Postgresql database has already initialized.', :magenta, true
      else
        run pg.run_cmd.call(:init)
      end
    end
    
    desc 'Set super users for postgresql.'
    task :set_super_users do
      pg.super_users.each do|user, password|
        sqls = ["CREATE USER #{user} WITH PASSWORD '#{password}';", "ALTER USER #{user} WITH SUPERUSER;"]
        sqls.each do|sql|
          run "psql -d postgres -c \"#{sql}\""
        end        
      end
    end
    
    [:start, :stop, :restart, :reload, :status].each do|cmd|
      desc "#{cmd} postgresql instance."
      task cmd do
        run pg.run_cmd.call(cmd)
      end
    end
  end
end