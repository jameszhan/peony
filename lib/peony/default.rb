set_default :base_dir,  "/u"
set_default :var_dir,   ->{ "#{base_dir}/var" }
set_default :etc_dir,   ->{ "#{base_dir}/etc" }
set_default :share_dir, ->{ "#{base_dir}/share" }
set_default :run_dir,   ->{ "#{var_dir}/run" }
set_default :tmp_dir,   ->{ "#{var_dir}/tmp" }
set_default :log_dir,   ->{ "#{var_dir}/log" }
set_default :www_dir,   ->{ "#{var_dir}/www" }
set_default :data_dir,  ->{ "#{var_dir}/data" }

set_default :user,  'james'
set_default :group, 'admin'

namespace :settings do
  desc 'List all the settings.'
  task :list do
    settings.each do|k, v|
      say "#{k} = #{settings.send(k)}", :green, true
    end
  end
end