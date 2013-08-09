require 'spec_helper'

describe SSHUtil do

  before(:each) do
    @temp_dir = Pathname.new('__temp__').expand_path
    FileUtils.mkdir_p(@temp_dir)
    @ssh = Net::SSH.start('localhost', ENV['USER'], password: "", timeout: 1)
  end

  after(:each) do
    @ssh.close
    FileUtils.rm_r(@temp_dir) if File.directory?(@temp_dir)
  end

  describe ".download" do

    it "download remote path" do
      remote_path = @temp_dir.join('__abc__').expand_path
      FileUtils.touch(remote_path)
      local_path = @temp_dir.join('__def__').expand_path
      SSHUtil.download(@ssh, remote_path, local_path)
      File.exist?(local_path).should be_true
    end
  end

  describe ".download_recursive" do

    it "download directory recursively" do
      remote_path = @temp_dir.join('remote').expand_path
      FileUtils.mkdir_p(remote_path)
      remote_path2 = remote_path.join('file').expand_path
      FileUtils.touch(remote_path2)
      local_path = @temp_dir.join('local')
      FileUtils.mkdir_p(local_path)
      SSHUtil.download_recursive(@ssh, remote_path, local_path)
      File.exist?(local_path.join('file')).should be_true
    end

    it "creates local directory if specified directory does not exist" do
      remote_path = @temp_dir.join('remote').expand_path
      FileUtils.mkdir_p(remote_path)
      remote_path2 = remote_path.join('file').expand_path
      FileUtils.touch(remote_path2)
      local_path = @temp_dir.join('local')

      SSHUtil.download_recursive(@ssh, remote_path, local_path)
      File.directory?(local_path).should be_true
      File.exist?(local_path.join('file')).should be_true
    end
  end

  describe ".upload" do

    it "upload local path" do
      local_path = @temp_dir.join('__abc__')
      FileUtils.touch(local_path)
      remote_path = @temp_dir.join('__def__').expand_path
      SSHUtil.upload(@ssh, local_path, remote_path)
      File.exist?(remote_path).should be_true
    end
  end

  describe ".rm_r" do

    before(:each) do
      @temp_file = @temp_dir.join('__abc__')
      FileUtils.touch(@temp_file)
    end

    it "removes specified file" do
      SSHUtil.rm_r(@ssh, @temp_file.expand_path)
      File.exist?(@temp_file).should be_false
    end

    it "removes specified directory even if the directory is not empty" do
      SSHUtil.rm_r(@ssh, @temp_dir.expand_path)
      File.directory?(@temp_dir).should be_false
    end
  end

  describe ".uname" do

    it "returns the result of 'uname' on remote host" do
      SSHUtil.uname(@ssh).should satisfy {|u|
        ["Linux", "Darwin"].include?(u)
      }
    end
  end

  describe ".execute" do

    it "executes command and returns its standard output" do
      SSHUtil.execute(@ssh, 'pwd').should eq ENV['HOME']
    end
  end

  describe ".execute_in_background" do

    it "executes command in background and return it immediately" do
      expect {
        SSHUtil.execute_in_background(@ssh, 'sleep 3')
      }.to change { Time.now }.by_at_most(1)
    end

    it "does not hung up when execute is called after execute_in_background" do
      expect {
        SSHUtil.execute_in_background(@ssh, 'sleep 3')
        SSHUtil.execute(@ssh, 'pwd')
      }.to change { Time.now }.by_at_most(1)
    end

    it "handles redirection properly" do
      remote_path = @temp_dir.join('abc').expand_path
      SSHUtil.execute_in_background(@ssh, "echo $USER > #{remote_path}")
      File.exist?(remote_path).should be_true
      File.open(remote_path).read.chomp.should eq ENV['USER']
    end
  end

  describe ".write_remote_file" do

    it "write contents to remote file" do
      output_file = @temp_dir.join('abc').expand_path
      SSHUtil.write_remote_file(@ssh, output_file, "foobar")
      File.open(output_file, 'r').read.should eq "foobar"
    end
  end
end
