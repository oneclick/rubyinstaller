def checkpoint(*names, &block)
  root = File.join(RubyInstaller::ROOT, 'sandbox')
  file File.join(root, ".#{names.join('-')}") do |f|
    yield if block_given?
    mkdir_p root unless File.directory?(root)
    touch f.name
  end
end
