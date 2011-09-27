def append_env(name, value, delim=';')
  env_name = name.to_s.upcase
  sane_value = value.gsub(File::SEPARATOR, File::ALT_SEPARATOR)
  old_value = ENV[env_name] || ''
  unless old_value.include?(sane_value) || old_value.include?(value)
    ENV[env_name] = "#{value}#{delim}" + old_value
  end
end

def activate(path)
  vars = {
    :path => File.join(RubyInstaller::ROOT, path, 'bin'),
    :cpath => File.join(RubyInstaller::ROOT, path, 'include'),
    :ldflags => File.join(RubyInstaller::ROOT, path, 'lib')
  }.reject { |k, v| !File.directory?(v) }

  vars.each do |k, v|
    case k
    when :ldflags
      append_env(k, "-L#{v}", ' ')
    else
      append_env(k, v)
    end
  end
end
