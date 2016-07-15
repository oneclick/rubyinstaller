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
      system "curl --silent -T #{path} -u #{username}:#{api_key} #{base_url}/#{version}/#{filename} > NUL 2>&1"

      success = $?.success?

      success or
        fail "Failed to upload #{filename}"
    end

    puts "Done."
  end

  desc "Get the md5 and sha256 digests and print them for a release"
  task :digests, [:version] do |_task, args|
    %w(md5 sha256).each do |digest_type|
      files = Dir.glob("pkg/#{args.version.strip}/*.#{digest_type}").sort
      puts "### #{digest_type.upcase}:"
      files.each do |file|
        puts "    #{File.read(file)}"
      end
      puts ''
    end
  end
end
