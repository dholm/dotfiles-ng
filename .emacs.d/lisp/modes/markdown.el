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
  :config
  (use-package flycheck-mmark
    :if (executable-find "mmark")
    :hook (flycheck-mode-hook . flycheck-mmark-setup))

  ;; Live preview, loaded when its command is first used.
  (use-package markdown-preview-mode
    :defer t))

;; Open Markdown files in polymode directly. Starting poly-markdown-mode
;; from the markdown-mode hook ran markdown-mode twice and replaced
;; gfm-mode with markdown-mode. Don't add markdown-mode entries here:
;; poly-markdown's autoloads already add the \.md entry, so a markdown-mode
;; entry added by this file would be tried before it.
(use-package poly-markdown
  ;; The more specific README entry comes last so that it is tried first.
  :mode (("\\.md\\'" . poly-markdown-mode)
         ("\\.markdown\\'" . poly-markdown-mode)
         ("README\\.md\\'" . poly-gfm-mode)))


(provide 'modes/markdown)
;;; markdown.el ends here
