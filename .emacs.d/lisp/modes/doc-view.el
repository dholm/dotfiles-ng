;;; doc-view.el --- Emacs document viewer -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package doc-view
  :defer
  :init
  (with-executable 'gs
    ;; Show PostScript files rendered, like PDF files. Emacs opens them in
    ;; ps-mode by default; C-c C-c switches between the two.
    (add-auto-mode 'doc-view-mode-maybe "\\.e?ps\\'"))
  :bind-wrap
  (:map doc-view-mode-map
        ((:key :nav :go-forward) . doc-view-scroll-up-or-next-page)
        ((:key :nav :go-back) . doc-view-scroll-down-or-previous-page))
  :config
  (validate-setq
   ;; Render documents in high resolution.
   doc-view-resolution 300)

  (use-package doc-present
    :quelpa (doc-present
             :fetcher github
             :repo "dengste/doc-present")
    :init
    (autoload 'doc-present "doc-present" nil t)
    (autoload 'doc-present-mode "doc-present" nil t)))


(provide 'modes/doc-view)
;;; doc-view.el ends here
