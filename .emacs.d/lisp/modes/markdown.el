;;; markdown --- initializes Markdown modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--markdown-mode-hook ()
  "Markdown mode hook."
  ;; Tables are edited with markdown-mode's own table support. orgtbl-mode
  ;; would rewrite the delimiter rows into Org syntax, which isn't GFM.
  (user/smartparens-enable))

(use-package markdown-mode
  :defer
  :hook (markdown-mode-hook . user--markdown-mode-hook)
  ;; use-package adds the entries in order, so the more specific README
  ;; entry has to come last to be tried first.
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :config
  (use-package flycheck-mmark
    :if (executable-find "mmark")
    :hook (flycheck-mode-hook . flycheck-mmark-setup))

  (use-package poly-markdown
    :hook (markdown-mode-hook . poly-markdown-mode))

  ;; Live preview, loaded when its command is first used.
  (use-package markdown-preview-mode
    :defer t))


(provide 'modes/markdown)
;;; markdown.el ends here
