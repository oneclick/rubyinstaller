namespace :release do
  desc "Upload release files"
  task :upload, [:version] do |t, args|
    base_url = "https://api.bintray.com/content/oneclick/rubyinstaller/rubyinstaller"
    version = args.version.strip

    version or
      fail "A version is required (e.g. 2.0.0-p247)"

    username = ENV.fetch("BINTRAY_USERNAME")
    api_key  = ENV.fetch("BINTRAY_API_KEY")

    files = Dir.glob("pkg/#{version}/*").sort

    files.each do |path|
      next unless File.file?(path)

      filename = File.basename(path)

      puts "Uploading: #{filename}"
      system "curl --silent -T #{path} -u #{username}:#{api_key} #{base_url}/#{version}/#{filename}"

      success = $?.success?

      success or
        fail "Failed to upload #{filename}"
    end

    puts "Done."
  end
end
