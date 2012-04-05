require 'ostruct'

module RubyInstaller
  interpreters = [RubyInstaller::Ruby18, RubyInstaller::Ruby19]

  interpreters.each do |package|

    core_glob    = File.join(package.target, "*.c")
    core_files   = Dir.glob(core_glob).map { |file| File.basename(file) }

    stdlib_files = [ './lib', './ext' ]

    doc_dir = File.join(RubyInstaller::ROOT, package.doc_target)


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
      )
    ]
  end
end
