require 'set'
require '../globby/lib/globby/glob'

module Globby
  class << self
    def select(patterns, source = get_files_and_dirs, result = {:files => Set.new, :dirs => Set.new})
      evaluate_patterns(patterns, source, result)
  
      if result[:dirs] && result[:dirs].size > 0
        # now go merge/subtract files under directories
        dir_patterns = result[:dirs].map{ |dir| "/#{dir}**" }
        evaluate_patterns(dir_patterns, {:files => source[:files]}, result)
      end

      result[:files].to_a.sort
    end
  
    def reject(patterns = [])
      source = get_files_and_dirs
      (source[:files] - select(patterns, source)).sort
    end
  
   private
  
    def evaluate_patterns(patterns, source, result)
      patterns.each do |pattern|
        next unless pattern =~ /\A[^#]/
        evaluate_pattern pattern, source, result
      end
    end

    def evaluate_pattern(pattern, source, result)
      glob = Globby::Glob.new(pattern)
      method, candidates = glob.inverse? ?
        [:subtract, result] :
        [:merge, source]
  
      dir_matches = glob.match(candidates[:dirs])
      file_matches = []
      file_matches = glob.match(candidates[:files]) unless glob.directory? || glob.exact_match? && !dir_matches.empty?
      result[:dirs].send method, dir_matches unless dir_matches.empty?
      result[:files].send method, file_matches unless file_matches.empty?
    end
  
    def get_files_and_dirs
      files, dirs = Dir.glob('**/*', File::FNM_DOTMATCH).
        reject { |f| f =~ /(\A|\/)\.\.?\z/ }.
        partition { |f| File.file?(f) || File.symlink?(f) }
      dirs.map!{ |d| d + "/" }
      {:files => files, :dirs => dirs}
    end
  end
end
