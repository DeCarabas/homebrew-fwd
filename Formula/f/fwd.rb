class Fwd < Formula
  desc "Small program to automatically forward connections to remote sockets"
  homepage "https://github.com/DeCarabas/fwd"

  on_macos do
    url "https://github.com/DeCarabas/fwd/releases/download/v0.8.1/fwd-x86_64-apple-darwin.tar.gz"
    sha256 "6ea27062d5ad7986cb68ee1b1702d6c421e329eda1668aa818faf35e9adc6aa5"
  end
  on_linux do
    url "https://github.com/DeCarabas/fwd/releases/download/v0.8.1/fwd-x86_64-unknown-linux-musl.tar.gz"
    sha256 "77b5eb149241e4b6c3f5db4ace50cc79d959c75b357c875fe78b5a01e307b164"
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
