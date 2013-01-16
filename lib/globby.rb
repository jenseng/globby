require 'set'

class Globby
  def initialize(patterns = [])
    @patterns = patterns
  end

  def matches
    result = Set.new
    @patterns.each do |pattern|
      if pattern[0, 1] == '!'
        result.subtract matches_for(pattern[1..-1])
      else
        result.merge matches_for(pattern)
      end
    end
    result.to_a.sort
  end

  def matches_for(pattern)
    return [] unless pattern = normalize(pattern)
    expects_dir = pattern.sub!(/\/\z/, '')

    files = Dir.glob(pattern, File::FNM_DOTMATCH | File::FNM_PATHNAME)
    result = []
    files.each do |file|
      next if ['.', '..'].include?(File.basename(file))
      if directory?(file)
        result.concat matches_for("/" + file + "/**/*")
      elsif !expects_dir
        result << file
      end
    end
    result
  end

  def normalize(pattern)
    pattern = pattern.strip
    first = pattern[0, 1]
    if pattern.empty? || first == '#'
      nil
    elsif first == '/'
      pattern[1..-1] 
    else
      "**/" + pattern  # could be anywhere
    end
  end

 protected

  def directory?(pattern)
    File.directory?(pattern) && !File.symlink?(pattern)
  end
end
