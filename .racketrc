;; NOTE: Only load xrepl readline support when in an interactive terminal
(when (regexp-match? #rx"term"
                     (getenv "TERM"))
  (dynamic-require 'xrepl #f))
