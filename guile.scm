(use-modules (ice-9 readline))
(activate-readline)

;; nil is not defined in guile by default, which is a real pain when
;; using code snippets from SICP or elsewhere.
(define nil '())
