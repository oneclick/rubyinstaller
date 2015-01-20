require 'ostruct'

module RubyInstaller
  interpreters = BaseVersions.collect { |ver|
    RubyInstaller.const_get("Ruby#{ver}")
  }

  interpreters.each do |package|
    doc_dir = File.join(RubyInstaller::ROOT, package.doc_target)

    core_glob    = File.join(package.target, "*.c")
    core_files   = Dir.glob(core_glob).map { |file| File.basename(file) }

    stdlib_files = [ './lib', './ext' ]
    language_files = [ './doc' ]

    package.docs = [
      core = OpenStruct.new(
        :lib => "core",
        :target  => File.join(doc_dir, "#{package.short_version}-core"),
        :title => "Ruby #{package.version} Core API Reference",
        :files => core_files
      ),
      stdlib = OpenStruct.new(
        :lib => "stdlib",
        :target  => File.join(doc_dir, "#{package.short_version}-stdlib"),
        :title => "Ruby #{package.version} Standard Library API Reference",
        :files => stdlib_files,
        :exclude  => "./lib/rdoc"
      ),
      language = OpenStruct.new(
        :lib => "language",
        :target  => File.join(doc_dir, "#{package.short_version}-language"),
        :title => "Ruby #{package.version} Language Reference",
        :files => language_files,
        :exclude  => "./lib/rdoc"
      )
    ]

    package.docs.each do |doc|
      # Build options
      opts = []
      opts.concat ['-x', doc.exclude] if doc.exclude
      doc.opts = opts unless opts.empty?

      # Build chm file names
      doc.chm_file_basename = "#{package.short_version}-#{doc.lib}.chm"
      doc.chm_file = File.join(RubyInstaller::ROOT, package.doc_target, doc.chm_file_basename)
    end

    # meta_chm for CHM format
    package.meta_chm = OpenStruct.new(
      :title => "Ruby #{package.version} Help file",
      :file  => File.join(package.doc_target, "#{package.short_version}.chm")
    )

    package.meta_chm.chm_file = File.join(RubyInstaller::ROOT, package.meta_chm.file)
  end
end
