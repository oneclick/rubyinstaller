module DevKitInstaller
  puts "Initializing DevKit compilers" if Rake.application.options.trace

  COMPILERS = {}

  # TODO update this list when adding any new compiler or compiler version!
  #      The format is a String consisting of vendor-bits-version
  VALID_COMPILERS = [
    'tdm-32-4.5.2',
    'tdm-32-4.5.1',
    'tdm-32-4.5.0',
    'tdm-64-4.5.1',
    'llvm-32-2.8',
    'mingw-32-4.5.2',
    'mingw-32-3.4.5',
    'mingw64-32-4.5.4',
    'mingw64-64-4.5.4',
  ]

end
