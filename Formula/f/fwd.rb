class Fwd < Formula
  desc "Small program to automatically forward connections to remote sockets"
  homepage "https://github.com/DeCarabas/fwd"

  on_macos do
    on_arm do
      url "https://github.com/DeCarabas/fwd/releases/download/v0.9.0/fwd-aarch64-apple-darwin.tar.gz"
      sha256 "d54ef3e44d1f29b9569ca5bbd8289c4a7ed6ed8ba5022af01d86eca236274605"
    end
    on_intel do
      url "https://github.com/DeCarabas/fwd/releases/download/v0.9.0/fwd-x86_64-apple-darwin.tar.gz"
      sha256 "08136cd3fc8445239f90b8b560bd8e99d63285fd20fa0b7a0879d8542a73420b"
    end
  end
  on_linux do
    url "https://github.com/DeCarabas/fwd/releases/download/v0.9.0/fwd-x86_64-unknown-linux-musl.tar.gz"
    sha256 "ddc4fdfab18af1864876458ca774b8f6c5f43dc156662a244c8496e6390345cf"
  end
  license "MIT"

  def install
    bin.install "fwd"
  end

  test do
    output_file = (testpath/"output.txt")

    # Make a fake ssh binary so that we can disable strict host key checking.
    # That way the test won't hang with any prompts.
    (testpath/"bin").mkpath
    fake_ssh = (testpath/"bin"/"ssh")
    fake_ssh.write <<~EOS
      #!/bin/sh
      /usr/bin/ssh -o "StrictHostKeyChecking=no" $*
    EOS
    chmod "+x", fake_ssh

    with_env(PATH: "#{testpath}/bin:#{ENV["PATH"]}") do
      pid = fork do
        ENV["SSH_ASKPASS"] = "never"
        ENV["SSH_ASKPASS_REQUIRE"] = "never"
        $stdout.reopen(output_file)
        $stderr.reopen($stdout)
        exec bin/"fwd", "fwd-brew-test@ssh.github.com"
      end
      sleep 5
      assert_match "fwd-brew-test@ssh.github.com", output_file.read.strip
    ensure
      Process.kill("TERM", pid)
      Process.wait pid
    end
  end
end
