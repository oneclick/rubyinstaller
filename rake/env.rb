def append_env(name, value)
  env_name = name.to_s.upcase
  sane_value = value.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  old_value = ENV[env_name] || ''
  unless old_value.include?(sane_value)
    ENV[env_name] = "#{sane_value};" + old_value
  end
end

def activate(path)
  vars = {
    :cpath => File.join(RubyInstaller::ROOT, path, 'include'),
    :library_path => File.join(RubyInstaller::ROOT, path, 'lib')
  }

  vars.delete_if { |k, v| !File.directory?(v) }
  vars.each do |k, v|
    append_env(k, v)
  end
end
