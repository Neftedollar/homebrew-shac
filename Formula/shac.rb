class Shac < Formula
  desc "Local shell autocomplete engine for bash, zsh, and fish"
  homepage "https://github.com/Neftedollar/sh-autocomplete"
  version "0.6.9"
  license "MIT"

  # Binary-install formula: downloads the prebuilt release tarball and installs
  # the binaries directly — no Rust/LLVM build toolchain is pulled for a normal
  # `brew install`. The macOS asset is a universal binary (arm64 + x86_64), so a
  # single url covers both Apple Silicon and Intel.
  #
  # CI (`.github/scripts/render_tap_formula.py`, run by release.yml) injects the
  # release-specific url + sha256 into the tap copy of this formula at tag time.
  # The url/sha256 committed here are the last-released values and serve as the
  # rendering template; they are not consumed by a normal tap install.
  on_macos do
    url "https://github.com/Neftedollar/sh-autocomplete/releases/download/v0.6.9/shac-macos-universal.tar.gz"
    sha256 "b6dd07fa0ca455625de765a3424c794fd37c2d1c3e5ab23adfd82927cb8c3198"
  end

  on_linux do
    url "https://github.com/Neftedollar/sh-autocomplete/releases/download/v0.6.9/shac-linux-x86_64.tar.gz"
    sha256 "9f29373a2e5078eed15fa04982e9a83f7911ae0d0d623f67529473b5bff049e0"
  end

  # `brew install --HEAD shac` still builds from source; only that opt-in path
  # needs the Rust toolchain.
  head do
    url "https://github.com/Neftedollar/sh-autocomplete.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args(path: ".")
    else
      bin.install "bin/shac", "bin/shacd"
    end
    pkgshare.install "shell"
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
