;;; fundamental.el --- Base mode of all other major modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--fundamental-mode-hook ()
  "Fundamental mode hook."
  ;; Break long lines automatically, but outside of text modes only in
  ;; comments, so that code and configuration lines aren't split.
  (unless (derived-mode-p 'text-mode)
    (setq-local comment-auto-fill-only-comments t))
  (auto-fill-mode t)

  ;; Enable whitespace mode globally.
  (whitespace-mode t)

  (with-feature 'rainbow-delimiters
    (rainbow-delimiters-mode t))

  ;; Enable dtrt-indent to attempt to identify the indentation rules used.
  (with-eval-after-load 'dtrt-indent
    (dtrt-indent-mode t))

  ;;; (Bindings) ;;;
  (user/bind-key-local :code :align 'align-current)
  (when (feature-p 'helm)
    (user/bind-key-local :nav :functions/toc 'helm-imenu)))


(defun user--fundamental-mode-config ()
  "Initialize Emacs fundamental mode."
  ;; When using fill-paragraph or auto-fill-mode break lines at 80 characters by
  ;; default. fill-column is buffer-local, so set the default value.
  (setq-default fill-column 80)

  ;;; (Packages) ;;;
  (use-package rainbow-delimiters)
  (use-package paren
    :ensure nil
    :config
    (validate-setq
     ;; Show the line of an open parenthesis that is off screen.
     show-paren-context-when-offscreen 'overlay)
    (show-paren-mode t))
  (use-package dynamic-spaces
    :config
    (dynamic-spaces-global-mode t))
  (use-package indent-info
    :config
    (global-indent-info-mode t))
  (use-package filladapt
    :disabled))

(user--fundamental-mode-config)


(provide 'modes/fundamental)
;;; fundamental.el ends here
