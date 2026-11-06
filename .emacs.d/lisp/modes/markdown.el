;;; markdown --- initializes Markdown modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-flymd-cache-directory*
  (path-join *user-cache-directory* "flymd")
  "Path to user's FLYMD cache store.")


(defun user--markdown-mode-hook ()
  "Markdown mode hook."
  (user/smartparens-enable)

  ;; org-mode table editing tools.
  (orgtbl-mode t))

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

  ;; Previewers, loaded when their commands are first used.
  (use-package markdown-preview-eww
    :defer t)
  (use-package markdown-preview-mode
    :defer t)

  (use-package mkdown
    :after markdown-mode
    :config
    (add-to-list 'markdown-css-paths mkdown-css-file-name))

  (use-package gh-md
    :defer t)

  (use-package flymd
    :defer t
    :init
    (make-directory *user-flymd-cache-directory* t)
    :config
    (validate-setq
     flymd-output-directory *user-flymd-cache-directory*)))


(provide 'modes/markdown)
;;; markdown.el ends here
