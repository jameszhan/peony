def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end


_cset :base_dir,  "/u"
_cset :etc_dir,   "#{base_dir}/etc"
_cset :var_dir,   "#{base_dir}/var"
_cset :tmp_dir,   "#{var_dir}/tmp"
_cset :run_dir,   "#{var_dir}/run"
_cset :data_dir,  "#{var_dir}/data"
