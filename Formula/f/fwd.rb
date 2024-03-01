class Fwd < Formula
  desc "Small program to automatically forward connections to remote sockets"
  homepage "https://github.com/DeCarabas/fwd"
  url "https://github.com/DeCarabas/fwd/archive/refs/tags/v0.8.1.tar.gz"
  sha256 "78bd3922817345755e4fb5348a53b4a88064cdbe6f0a01bf6ef412fac3c87944"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
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
