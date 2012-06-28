# Additional tasks for the knapsack openssl package

namespace(:dependencies) do
  namespace(:openssl) do
    task :activate => [:prepare]

    task :prepare => [:extract] do
       # Set environment variable for usage of OpenSSL::Config::DEFAULT_CONFIG_FILE
       # The constant is used in OpenSSL::TestConfig#test_constants.

       target = RubyInstaller::KNAPSACK_PACKAGES['openssl'].target
       ENV['OPENSSL_CONF'] = File.join(RubyInstaller::ROOT, target, 'ssl/openssl.cnf')
    end
  end
end
