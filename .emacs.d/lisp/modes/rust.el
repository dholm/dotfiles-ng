;;; rust.el --- Rust mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package rustic
  :if (executable-find "rustc")
  :defer
  :mode ("\\.rs$" . rustic-mode)
  ;; Use Eglot like the other languages, and only when rust-analyzer is
  ;; installed.
  :hook (rustic-mode-hook . user/eglot-ensure)
  :init
  (setq
   ;; Must be set before rustic-lsp loads, which otherwise starts the
   ;; client from `rustic-mode-hook'.
   rustic-lsp-setup-p nil
   rustic-lsp-client 'eglot))


(provide 'modes/rust)
;;; rust.el ends here
