scope :php do
  set_default :home,          ->{ "#{share_dir}/php5" }
  set_default :php_cgi,       ->{ "#{php.home}/bin/php-cgi" }
  set_default :spawn_fcgi,    '/usr/local/bin/spawn-fcgi'
  set_default :fcgi_run_dir,  ->{ "#{run_dir}/fcgi" }
  set_default :fcgi_address,  '127.0.0.1'
  set_default :fcgi_port,     6666
  set_default :fcgi_children, 6
end

namespace :php do
  namespace :fcgi do
    desc 'Create fcgi running directory.'
    task :init do
      mkdir_p("#{run_dir}/fcgi")
    end
    
    desc 'Start fcgi.'
    task :start => :init do
      run "#{php.spawn_fcgi} -a #{php.fcgi_address} -p #{php.fcgi_port} -C #{php.fcgi_children} -f #{php.php_cgi} -u #{user} -d #{php.fcgi_run_dir} -P #{php.fcgi_run_dir}/spawn_fcgi.pid > /dev/null"
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