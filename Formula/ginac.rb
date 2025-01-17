class Ginac < Formula
  desc "Not a Computer algebra system"
  homepage "https://www.ginac.de/"
  url "https://www.ginac.de/ginac-1.8.2.tar.bz2"
  sha256 "bfcd751abcaf8afddb83958c2ad22763a75ea24032553e503ee9b38e3ea3b6c3"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.ginac.de/Download.html"
    regex(/href=.*?ginac[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any,                 monterey:     "8f0a3d73801e6075b0d327b96163cdee33f343f4e92b98b3afc17cb647aef67f"
    sha256 cellar: :any,                 big_sur:      "d4506efbe735f7e139855cfe63089fe8f69ad79332ef6a6e52191666af53c552"
    sha256 cellar: :any,                 catalina:     "91f8da2327e83022ab1198c80a3aea34d2bed2cd12d1940915f3963aa9f15351"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0f3350bc62359b413ec62d69009139977641a97068edf8ae8aad7bb5c7eaa6f1"
  end

  depends_on "pkg-config" => :build
  depends_on "cln"
  depends_on "python@3.10"
  depends_on "readline"

  # Fix -flat_namespace being used on Big Sur and later.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
    sha256 "35acd6aebc19843f1a2b3a63e880baceb0f5278ab1ace661e57a502d9d78c93c"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <ginac/ginac.h>
      using namespace std;
      using namespace GiNaC;

      int main() {
        symbol x("x"), y("y");
        ex poly;

        for (int i=0; i<3; ++i) {
          poly += factorial(i+16)*pow(x,i)*pow(y,2-i);
        }

        cout << poly << endl;
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}",
                                "-L#{Formula["cln"].lib}",
                                "-lcln", "-lginac", "-o", "test",
                                "-std=c++11"
    system "./test"
  end
end
