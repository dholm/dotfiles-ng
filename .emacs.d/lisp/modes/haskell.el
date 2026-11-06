;;; haskell.el --- initializes Haskell modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--generic-haskell-mode-hook ()
  "Generic Haskell mode hook."
  (turn-on-haskell-doc-mode)

  ;; Enable editing of camel case
  (subword-mode t)

  (user/smartparens-enable)

  ;;; (Bindings) ;;;
  (user/bind-key-local :doc :reference 'hoogle))


(defun user--haskell-mode-hook ()
  "Haskell mode hook."
  (user--generic-haskell-mode-hook)
  (turn-on-haskell-indentation)

  ;; Enable LSP, if a language server is installed.
  (user/eglot-ensure))


(defun user--inferior-haskell-mode-hook ()
  "Inferior Haskell mode hook."
  (user--generic-haskell-mode-hook))

(use-package haskell-mode
  :if (executable-find "ghc")
  :hook ((haskell-mode-hook . user--haskell-mode-hook)
         (inferior-haskell-mode-hook . user--inferior-haskell-mode-hook))
  :config
  ;;; (Packages) ;;;
  (use-package flycheck-haskell))


(provide 'modes/haskell)
;;; haskell.el ends here
