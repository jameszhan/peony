set_default :pg_home, ->{`brew --prefix postgresql`.strip}
set_default :pg_initdb, "/usr/local/bin/initdb"
set_default :pg_ctl, "/usr/local/bin/pg_ctl"

set_default :pg_data_dir, ->{"#{data_dir}/pgsql"}
set_default :pg_init, ->{"#{pg_initdb} -D #{pg_data_dir} --debug"}
set_default :pg_start, ->{"#{pg_ctl} -D #{pg_data_dir} -l #{log_dir}/pgsql.log start"}
set_default :pg_stop, ->{"#{pg_ctl} -D #{pg_data_dir} stop"}
set_default :pg_restart, ->{"#{pg_ctl} -D #{pg_data_dir} -l #{log_dir}/pgsql.log restart"}

set_default :pg_super_users, {
  pgsql: "123456"
}

namespace :db do
  namespace :pg do
    task :init do
      if File.exists?("#{pg_data_dir}/postgresql.conf")
        puts "Postgresql database has already initialized."
      else
        sh pg_init do |res, stat|
          puts stat.inspect if !res
        end
      end
    end
    
    task :set_super_users do
      pg_super_users.each do|user, password|
        sqls = ["CREATE USER #{user} WITH PASSWORD '#{password}';", "ALTER USER #{user} WITH SUPERUSER;"]
        sqls.each do|sql|
          sh "psql -d postgres -c \"#{sql}\"" do|res, stat|
            puts stat.inspect if !res
          end
        end        
      end
    end
    
    [:start, :stop, :restart].each do|cmd|
      task cmd do
        sh self.send("pg_#{cmd}") do|res, stat|
          puts stat.inspect if !res
        end
      end
    end
  end
end