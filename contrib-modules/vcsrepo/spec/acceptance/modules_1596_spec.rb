require 'spec_helper_acceptance'

tmpdir = default.tmpdir('vcsrepo')

describe 'clones a remote repo' do
  before(:all) do
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
    shell("mkdir -p #{tmpdir}") # win test
  end

  after(:all) do
    shell("rm -rf #{tmpdir}/vcsrepo")
  end

  context 'with force with a remote' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/vcsrepo":
        ensure   => present,
        provider => git,
        source   => 'https://github.com/puppetlabs/puppetlabs-vcsrepo',
        force    => true,
      }
    MANIFEST
    it 'clones from remote' do
      # Run it twice to test for idempotency
      apply_manifest(pp, catch_failures: true)
      # need to create a file to make sure we aren't destroying the repo
      # because fun fact, if you call destroy/create in 'retrieve' puppet won't
      # register that any changes happen, because that method isn't supposed to
      # be making any changes.
      shell("touch #{tmpdir}/vcsrepo/foo")
      apply_manifest(pp, catch_changes: true)
    end

    describe file("#{tmpdir}/vcsrepo/foo") do
      it { is_expected.to be_file }
    end
  end

  context 'with force over an existing repo' do
    pp = <<-MANIFEST
      vcsrepo { "#{tmpdir}/vcsrepo":
        ensure   => present,
        provider => git,
        source   => 'https://github.com/puppetlabs/puppetlabs-vcsrepo',
        force    => true,
      }
    MANIFEST

    pp2 = <<-MANIFEST
      vcsrepo { "#{tmpdir}/vcsrepo":
        ensure   => present,
        provider => git,
        source   => 'https://github.com/puppetlabs/puppetlabs-stdlib',
        force    => true,
      }
    MANIFEST
    it 'clones from remote' do
      apply_manifest(pp, catch_failures: true)
      # create a file to make sure we're destroying the repo
      shell("touch #{tmpdir}/vcsrepo/foo")
      apply_manifest(pp2, catch_failures: true)
    end

    describe file("#{tmpdir}/vcsrepo/foo") do
      it { is_expected.not_to be_file }
    end
  end
end
