;;; lisp.el --- Initializes Lisp modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--lisp-mode-common-hook ()
  "Lisp mode hook."
  (setq-local
   ;; Indent using spaces.
   indent-tabs-mode nil)

  (user--cedet-hook)

  (user/gnu-global-enable)

  (with-feature 'rainbow-delimiters
    (rainbow-delimiters-mode t))

  (with-feature 'paredit
    ;; Paredit's RET and C-j would shadow evaluation in IELM and in
    ;; *scratch*.
    (unless (derived-mode-p 'inferior-emacs-lisp-mode 'lisp-interaction-mode)
      (enable-paredit-mode)))

  (with-feature 'easy-escape
    (easy-escape-minor-mode t))

  (turn-on-eldoc-mode)

  ;;; (Bindings) ;;;
  (user/bind-key-local :code :eval-buffer 'eval-buffer)
  (user/bind-key-local :code :eval-function 'eval-defun)
  (user/bind-key-local :code :eval-selection 'eval-region)
  (user/bind-key-local :code :eval-expression 'eval-last-sexp))


(defun user--lisp-mode-hook ()
  "Lisp mode hook."
  (user--lisp-mode-common-hook))


(use-package lisp-mode
  :ensure nil
  :defer
  :hook (lisp-mode-hook . user--lisp-mode-hook)
  :config
  (use-package easy-escape
    :defer t
    :diminish easy-escape-minor-mode))


;; At top level rather than in lisp-mode's :config, which runs at startup
;; because lisp-mode is preloaded.
(use-package slime
  :defer t
  ;; SLIME's own hook turns on `slime-mode'. `slime-setup' adds it when
  ;; SLIME loads, which now only happens for the first Lisp buffer.
  :hook (lisp-mode-hook . slime-lisp-mode-hook)
  :config
  (validate-setq
   slime-protocol-version 'ignore
   slime-net-coding-system 'utf-8-unix
   ;; Set the preferred available inferior lisp program.
   inferior-lisp-program
   (cond
    ((executable-find "sbcl") "sbcl")
    ((executable-find "lisp") "lisp")
    ((executable-find "clisp") "clisp -K full")
    (t inferior-lisp-program)))

  (slime-setup '(slime-repl))

  (use-package slime-repl-ansi-color
    :hook (slime-repl-mode-hook . slime-repl-ansi-color-mode)))


(provide 'modes/lisp)
;;; lisp.el ends here
