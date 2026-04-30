class Shac < Formula
  desc "Local shell autocomplete engine for bash, zsh, and fish"
  homepage "https://github.com/Neftedollar/sh-autocomplete"
  url "https://github.com/Neftedollar/sh-autocomplete/archive/refs/tags/v0.5.2.tar.gz"
  sha256 "dee3f986a11b9622f067916bb86e04943deea3876d92d96e94171502be667b3d"
  license "MIT"
  head "https://github.com/Neftedollar/sh-autocomplete.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: ".")
    pkgshare.install "shell"
  end

  def post_install
    # Restart the daemon if it is already registered with launchd, so the new
    # binary is picked up immediately after upgrade. Skipped on fresh install
    # (launchd entry doesn't exist yet). The user still needs `exec $SHELL` in
    # open sessions to refresh _shac_client_version.
    if system("launchctl", "list", "homebrew.mxcl.shac", out: IO::NULL, err: IO::NULL)
      system "#{HOMEBREW_PREFIX}/bin/brew", "services", "restart", "shac"
    end
  rescue StandardError
    nil
  end

  service do
    run [opt_bin/"shacd"]
    keep_alive true
    log_path var/"log/shac.log"
    error_log_path var/"log/shac.log"
  end

  def caveats
    <<~EOS
      Install shell integration with:
        shac install --shell zsh --edit-rc

      Start the daemon (auto-restarts on login via launchd):
        brew services start shac

      Or start manually without launchd:
        shac daemon start

      Check status:
        shac doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/shac --version")
    assert_match "stopped", shell_output("#{bin}/shac daemon status")
  end
end
