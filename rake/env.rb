def append_env(name, value)
  env_name = name.to_s.upcase
  sane_value = value.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  old_value = ENV[env_name] || ''
  unless old_value.include?(sane_value)
    ENV[env_name] = "#{sane_value};" + old_value
  end
end
