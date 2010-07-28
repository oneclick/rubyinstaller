class String
  # Converts a lower case and underscored string to UpperCamelCase.
  #
  # Examples:
  #   "ruby_build_path".camelcase   # => "RubyBuildPath"
  def camelcase
    self.gsub(/(?:\A|_)(.)/) { $1.upcase }
  end
end
