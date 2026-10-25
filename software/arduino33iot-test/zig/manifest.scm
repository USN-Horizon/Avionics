(use-modules
  (guix)
  (guix build-system copy)
  ((guix licenses) #:prefix license:))


(define zig-0.17
  (package
    (name "zig")
    (version "0.17")
    (source
      (origin
        (method url-fetch)
        (uri "https://ziglang.org/download/0.17.0/zig-x86_64-linux-0.17.0.tar.xz")
        (sha256
          (base32 "09i09s6hhzqxj3g67i7ikvvlwh1sf2v47jnb9k8phsvyybwrvghw"))))
    (build-system copy-build-system)
    (arguments
      '(#:install-plan '(("." "bin/"))))
    (home-page "https://ziglang.org")
    (synopsis "Zig")
    (description "Zig")
    (license license:expat)))

(packages->manifest (list zig-0.17))
