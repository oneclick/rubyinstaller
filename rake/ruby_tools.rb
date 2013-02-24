module RubyTools
  # use provided ruby.exe to figure out runtime information
  def self.parse_ruby(ruby_exe)
    result = `#{ruby_exe} -rrbconfig -ve \"puts 'ruby_version: %s' % RbConfig::CONFIG['ruby_version']\"`
    return nil unless $?.success?
    return nil if result.empty?

    h = {}

    if result =~ /(\d\.\d.\d)/
      h[:version] = $1
    end

    if result =~ /patchlevel (\d+)/
      h[:patchlevel] = $1
    end

    if result =~ /\dp(\d+)/
      h[:patchlevel] = $1
    end

    if result =~ /ruby_version: (\S+)/
      h[:lib_version] = $1
    end

    if result =~ /\[(\S+)\]/
      h[:platform] = $1
    end

    if result =~ /trunk (\d+)/
      h[:revision] = $1
    end

    if result =~ /(\d+-\d+-\d+)/
      h[:release_date] = $1
    end

    # construct either X.Y.Z-p123 or X.Y.Z-rNNNN (dev)
    version_human = h[:version].dup
    if h[:patchlevel]
      version_human << "-p%s" % h[:patchlevel]
    else
      version_human << "-r%s" % h[:revision]
    end

    h[:version_human] = version_human

    major_minor       = h[:version][0..2]
    namespace_version = major_minor.sub('.', '')

    h[:namespace_version] = namespace_version

    h
  end
end
