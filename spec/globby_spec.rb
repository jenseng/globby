require 'globby'
RSpec.configure { |config| config.mock_framework = :mocha }

# A blank line matches no files, so it can serve as a separator for
# readability.
# 
# A line starting with # serves as a comment.
# 
# An optional prefix ! which negates the pattern; any matching file excluded by
# a previous pattern will become included again. If a negated pattern matches,
# this will override lower precedence patterns sources.
# 
# If the pattern ends with a slash, it is removed for the purpose of the 
# following description, but it would only find a match with a directory. In 
# other words, foo/ will match a directory foo and paths underneath it, but
# will not match a regular file or a symbolic link foo (this is consistent with
# the way how pathspec works in general in git).
# 
# If the pattern does not contain a slash /, git treats it as a shell glob 
# pattern and checks for a match against the pathname relative to the location
# of the .gitignore file (relative to the toplevel of the work tree if not from
# a .gitignore file).
# 
# Otherwise, git treats the pattern as a shell glob suitable for consumption by 
# fnmatch(3) with the FNM_PATHNAME flag: wildcards in the pattern will not
# match a / in the pathname. For example, "Documentation/*.html" matches 
# "Documentation/git.html" but not "Documentation/ppc/ppc.html" or 
# "tools/perf/Documentation/perf.html".
# 
# A leading slash matches the beginning of the pathname. For example, "/*.c" 
# matches "cat-file.c" but not "mozilla-sha1/sha1.c".

describe Globby do
  describe "#matches_for" do

    let(:globby) { Globby.new }
  
    context "a blank line" do
      it "should return nothing" do
        Dir.expects(:glob).never
        globby.matches_for("").should == []
      end
    end

    context "a comment" do
      it "should return nothing" do
        Dir.expects(:glob).never
        globby.matches_for("#comment").should == []
      end
    end

    context "a pattern ending in a slash" do
      it "should return a matching directory's contents" do
        globby.stubs(:directory?).returns true, false
        Dir.expects(:glob).twice.returns ["foo"], ['foo/bar']
        globby.matches_for("foo/").should == ['foo/bar']
      end

      it "should ignore symlinks and regular files" do
        globby.stubs(:directory?).returns false
        Dir.expects(:glob).once.returns ["foo"]
        globby.matches_for("foo/").should == []
      end
    end

    context "a pattern without a slash" do
      it "should return all glob matches" do
        Dir.expects(:glob).with{ |*args| args.first == "**/*rb"}.returns []
        globby.matches_for("*rb")
      end
    end

    context "a pattern with a slash" do
      it "should return all glob matches" do
        Dir.expects(:glob).with{ |*args| args.first == "**/foo/bar"}.returns []
        globby.matches_for("foo/bar")
      end
    end

    context "a pattern starting in a slash" do
      it "should return all root glob matches" do
        Dir.expects(:glob).with{ |*args| args.first == "foo/bar"}.returns []
        globby.matches_for("/foo/bar")
      end
    end
  end

  describe "#matches" do
    it "should match gitignore perfectly" do
      require 'tmpdir'
      require 'fileutils'

      files = <<-FILES.strip.split(/\s+/)
        .gitignore
        foo.rb
        foo.html
        bar
        baz/lol.txt
        foo/.hidden
        foo/bar.rb
        foo/bar.html
        foo/bar/baz.pdf
        foobar/.hidden
        foobar/baz.txt
        foobar/baz.rb
        foobar/baz/lol.wut
      FILES

      ignore = <<-IGNORE.gsub(/^ +/, '')
        # here we go...

        # some dotfiles
        .hidden

        # html, but just in the root
        /*.html

        # all rb files anywhere
        *.rb

        # except rb files immediately under foobar
        !foobar/*.rb

        # this will match foo/bar but not bar
        bar/

        # this will match nothing
        foo*bar/baz.pdf

        # this will match baz/ and foobar/baz/
        baz
      IGNORE

      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.open('.gitignore', 'w'){ |f| f.write ignore }
          files.each do |file|
            FileUtils.mkdir_p File.dirname(file)
            FileUtils.touch file
          end

          `git init .`
          untracked = `git status -uall`.gsub(/.*#\n|#\s+|^nothing.*/m, '').split(/\n/)

          globby = Globby.new(ignore.split(/\n/))
          ignored = globby.matches
          
          all_files = Dir.glob('**/*', File::FNM_DOTMATCH | File::FNM_PATHNAME).
            reject{ |f| f =~ /^\.git\// }.
            select{ |f| File.symlink?(f) || File.file?(f) }
          
          all_files.sort.should == (untracked + ignored).sort 
        end
      end
    end
  end
end