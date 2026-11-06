;;; ruby.el --- ruby mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--ruby-mode-hook ()
  "Ruby mode hook."
  ;; Bring in CEDET.
  (user--cedet-hook)

  (user/gnu-global-enable)

  ;; Enable inferior ruby mode
  (when (fboundp 'inf-ruby-minor-mode)
    (inf-ruby-minor-mode t))

  ;; Enable eldoc mode
  (eldoc-mode t)

  ;; Separate camel-case into separate words
  (subword-mode t)

  ;; Enable LSP, if a language server is installed.
  (user/eglot-ensure))


(use-package ruby-mode
  :defer
  ;; ruby-base-mode-hook also runs in ruby-ts-mode.
  :hook (ruby-base-mode-hook . user--ruby-mode-hook)
  :bind
  (:map ruby-mode-map
        ("TAB" . indent-for-tab-command))
  :config
  (use-package robe
    :hook (ruby-base-mode-hook . robe-mode)
    :config
    (with-eval-after-load 'company
      (push 'company-robe company-backends)))
  (use-package inf-ruby)
  (use-package yari
    :bind-wrap
    (:map ruby-mode-map
          ((:key :doc :reference) . yari)))
  (use-package rubocopfmt
    :if (executable-find "rubocop")
    :hook (ruby-mode-hook . rubocopfmt-mode)))


(provide 'modes/ruby)
;;; ruby.el ends here
