require 'globby'

RSpec.configure { |config| config.mock_framework = :mocha }

describe Globby do
  describe ".select" do
    context "a blank line" do
      it "should return nothing" do
        files = files("foo")
        Globby.select([""], files).should == []
      end
    end

    context "a comment" do
      it "should return nothing" do
        files = files("foo")
        Globby.select(["#"], files).should == []
      end
    end

    context "a pattern ending in a slash" do
      it "should return a matching directory's contents" do
        files = files(%w{foo/bar/baz foo/bar/baz2})
        Globby.select(%w{bar/}, files).should == %w{foo/bar/baz foo/bar/baz2}
      end

      it "should ignore symlinks and regular files" do
        files = files(%w{foo/bar bar/baz})
        Globby.select(%w{bar/}, files).should == %w{bar/baz}
      end
    end

    context "a pattern starting in a slash" do
      it "should return only root glob matches" do
        files = files(%w{foo/bar bar/foo})
        Globby.select(%w{/foo}, files).should == %w{foo/bar}
      end
    end

    context "a pattern with a *" do
      it "should return matching files" do
        files = files(%w{foo/bar foo/baz})
        Globby.select(%w{*z}, files).should == %w{foo/baz}
      end

      it "should not glob slashes" do
        files = files(%w{foo/bar foo/baz})
        Globby.select(%w{foo*bar}, files).should == []
      end
    end

    context "a pattern with a ?" do
      it "should return matching files" do
        files = files(%w{foo/bar foo/baz})
        Globby.select(%w{b?z}, files).should == %w{foo/baz}
      end

      it "should not glob slashes" do
        files = files(%w{foo/bar foo/baz})
        Globby.select(%w{foo?bar}, files).should == []
      end
    end

    context "a pattern with a **" do
      it "should match directories recursively" do
        files = files(%w{foo/bar foo/baz foo/c/bar foo/c/c/bar})
        Globby.select(%w{foo/**/bar}, files).should == %w{foo/bar foo/c/bar foo/c/c/bar}
      end
    end

    context "a pattern with bracket expressions" do
      it "should return matching files" do
        files = files(%w{boo fob f0o foo/bar poo/baz})
        Globby.select(%w{[e-g][0-9[:alpha:]][!b]}, files).should == %w{f0o foo/bar}
      end
    end
  end

  def files(files)
    files = Array(files)
    files.sort!
    dirs = files.grep(/\//).map { |file| file.sub(/[^\/]+\z/, '') }.uniq.sort
    {:files => files, :dirs => dirs}
  end
end