class Fwd < Formula
  desc "Small program to automatically forward connections to remote sockets"
  homepage "https://github.com/DeCarabas/fwd"

  on_macos do
    on_arm do
      url "https://github.com/DeCarabas/fwd/releases/download/v0.9.1/fwd-aarch64-apple-darwin.tar.gz"
      sha256 "55d27ee226656ccb7f29f71a394bcd824cb97120f1a6b69a233d0e29d84a06be"
    end
    on_intel do
      url "https://github.com/DeCarabas/fwd/releases/download/v0.9.1/fwd-x86_64-apple-darwin.tar.gz"
      sha256 "42ae57d89ff3859a0f2183578fe4371569f1e5079ece1edc06e1436bd2c301c5"
    end
  end
  on_linux do
    url "https://github.com/DeCarabas/fwd/releases/download/v0.9.1/fwd-x86_64-unknown-linux-musl.tar.gz"
    sha256 "282c9379a1aebee2c359dec3c8db2312f32ca602ce5aaebba924db3ddf53e33e"
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
