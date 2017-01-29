(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-file-name-transforms (quote ((".*" "~/.emacs.d/autosaves/\\1" t))))
 '(backup-directory-alist (quote ((".*" . "~/.emacs.d/backups/"))))
 '(before-save-hook (quote (whitespace-cleanup)))
 '(custom-enabled-themes (quote (tango-dark)))
 '(evil-indent-convert-tabs t)
 '(global-whitespace-mode t)
 '(horizontal-scroll-bar-mode t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(neo-window-fixed-size nil)
 '(neo-window-width 40)
 '(scheme-program-name "guile")
 '(show-paren-mode t)
 '(standard-indent 4)
 '(tab-stop-list
   (quote
    (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120)))
 '(tab-width 4)
 '(truncate-lines t)
 '(whitespace-style
   (quote
    (face tabs trailing space-before-tab empty space-after-tab tab-mark))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; config of builtin features
;; create the autosave dir if necessary, since emacs won't.
(make-directory "~/.emacs.d/autosaves/" t)

;; Always show column number with line number
(column-number-mode)
;; Always show line numbers in gutter
(global-linum-mode t)
;; always save the desktop layout
;; (desktop-save-mode t)

;; config external packages
;; make sure package manager is loaded and has extra repos
(require 'package)
(push '("marmalade" . "http://marmalade-repo.org/packages/") package-archives)
;; melpa stuff is too bleeding edge most of the time. Use melpa stable instead.
(push '("melpa-stable" . "https://stable.melpa.org/packages/") package-archives)
(push '("melpa" . "https://melpa.org/packages/") package-archives)
(package-initialize)

;; make sure 'use-package package is loaded
(if (not (package-installed-p 'use-package))
  (progn
    (package-refresh-contents)
    (package-install 'use-package)))

(require 'use-package)

(use-package evil
  :ensure t)
(evil-mode 1)
(modify-syntax-entry ?_ "w") ;; ignore underscores in words, like vim does

;; for evil mode. pulled from: https://github.com/davvil/.emacs.d/blob/master/init.el
;; esc quits pretty much everything
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.

   In Delete Selection mode, if the mark is active, just deactivate it;
   then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'evil-exit-emacs-state)

;; (use-package evil-search-highlight-persist
;;   :ensure t)
;; (global-evil-search-highlight-persist t)

;; Using visual selection is more portable and it is still fairly easy to do
;; (use-package evil-commentary
;;   :ensure t)
;; (evil-commentary-mode)

;; (use-package ergoemacs-mode
;;   :ensure t)

;; (setq ergoemacs-theme nil)
;; (setq ergoemacs-keyboard-layout "us")
;; (require 'ergoemacs-mode)
;; (ergoemacs-mode 1)

;; NOTE: git-gutter isn't working right now, so just disable it for
;; the time being.

;; (use-package git-gutter
;;   :ensure t)
;; (git-gutter)

(use-package pep8
  :ensure t)

(use-package pyflakes
  :ensure t)

(use-package neotree
  :ensure t)

;; Extra major modes to always have available
(use-package llvm-mode
  :ensure t)

(use-package markdown-mode
  :ensure t)

(use-package racket-mode
  :ensure t)

;; Apparently quack is pretty awesome for scheme and racket
(use-package quack
  :ensure t)

(require 'quack)

;; at flymake hook for python's pyflakes
(use-package flymake-python-pyflakes
  :ensure t)
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)

;; use flake8 instead of pyflakes
(setq flymake-python-pyflakes-executable "flake8")

;; extra args to pyflakes executable
;; (setq flymake-python-pyflakes-extra-arguments '("--ignore=W806"))

;; Custom functions

(defun comment-or-uncomment-line-or-region ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
        (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

;; Since using Evil mode lately, this has become less useful. In fact,
;; I'm not sure that it ever actually worked.
;; (global-set-key (kbd "C-/") 'comment-or-uncomment-region-or-line)

(defun revert-all-buffers ()
  "Refreshes all openbuffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (file-exists-p (buffer-file-name)) (not (buffer-modified-p)))
        (revert-buffer t t t) )))
  (message "Refreshed open files."))

(defun kill-other-buffers ()
  "Kill all other buffers aside from current one."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list)))
  (message "Killed all other buffers."))

;; Pylama grepper
(defvar pylama-hist nil)

(defgroup pylama nil
  "Run pylama putting hits in a grep buffer."
  :group 'tools
  :group 'processes)

(defcustom pylama-cmd "pylama --linters mccabe,pep8,pylint,pyflakes,pep257"
  "The pylama command."
  :type 'string
  :group 'pylama)

;;; ###autoload

(defun pylama ()
  (interactive)
  (let* ((cmd (read-shell-command "Command: "
                                  (concat pylama-cmd
                                          " "
                                          (file-name-nondirectory (or (buffer-file-name) "")))
                                  'pylama-hist))
         (null-device nil))
    (grep cmd)))

(provide 'pylama)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; End Pylama grepper

;; Unfill code originally from:
;; https://www.emacswiki.org/emacs/UnfillRegion

(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single
logical line.  This is useful, e.g., for use with
`visual-line-mode'."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))
