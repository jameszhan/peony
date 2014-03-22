set_default :php_home, ->{"#{share_dir}/php5"}
set_default :php_cgi, ->{"#{php_home}/bin/php-cgi"}
set_default :spawn_fcgi, "/usr/local/bin/spawn-fcgi"
set_default :fcgi_run_dir, ->{"#{run_dir}/fcgi"}

namespace :php do
  namespace :fcgi do
    desc 'Create fcgi running directory.'
    task :init do
      mkdir_p("#{run_dir}/fcgi")
    end
    
    desc 'Start fcgi.'
    task :start => :init do
      run "#{spawn_fcgi} -a 127.0.0.1 -p 6666 -C 6 -f #{php_cgi} -u #{user} -P #{fcgi_run_dir}/spawn_fcgi.pid > /dev/null"
    end
    
    desc 'Kill fcgi.'
    task :stop do
      run 'killall -9 php-fcgi > /dev/null 2>&1 || echo -n  "not running"' 
    end
    
    desc 'Restart fcgi.'
    task :restart => :stop do
      invoke 'php:fcgi:stop'
      sleep(6)
      invoke 'php:fcgi:start'
    end
  end
end