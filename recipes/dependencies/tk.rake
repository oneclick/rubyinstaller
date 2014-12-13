namespace(:dependencies) do
  namespace(:tk) do
    package = RubyInstaller::KNAPSACK_PACKAGES['tk']
    directory package.target

    RubyInstaller::BaseVersions.each do |ver|
      interpreter = RubyInstaller.const_get("Ruby#{ver}")
      task "install#{ver}" => [:activate, interpreter.install_target, *package.dependencies] do
        tcltk_install interpreter
        tk_patch package, interpreter
      end
    end

  private

    def tcltk_install(interpreter)
      # DLLs are already copied by ruby own install task, so copy the remaining bits
      target = File.join(interpreter.install_target, "lib", "tcltk")
      mkdir_p target

      ['tcl', 'tk'].each do |pkg|
        pkg_dir = RubyInstaller::KNAPSACK_PACKAGES[pkg].target
        pattern = "#{pkg_dir}/lib/*"
        Dir.glob(pattern).each do |f|
          next if f =~ /\.(a|sh)$/

          if File.directory?(f)
            cp_r f, target, :remove_destination => true
          else
            cp_f f, target
          end
        end
      end
    end

    def tk_patch(package, interpreter)
      target = Dir.glob("#{interpreter.install_target}/lib/ruby/**/tk.rb").first
      parent = File.dirname(target)

      # use diffs instead of patch so we can apply post_install
      diffs = Dir.glob("#{package.patches}/*.diff").sort
      diffs.each do |diff|
        # verify that diff can be applied
        result = system("git apply --check --directory #{parent} #{diff} > NUL 2>&1")
        if result
          sh "git apply --directory #{parent} #{diff}"
        end
      end
    end
  end
end
