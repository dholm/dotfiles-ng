;;; symbols.el --- Configure how Emacs handles certain symbols -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package page-break-lines
  :diminish page-break-lines-mode
  :config
  (global-page-break-lines-mode t))

(use-package all-the-icons
  ;; Loaded by the packages that use it. Not tied to `window-system' at
  ;; startup, which is nil under the daemon even when GUI frames follow.
  :defer t)


(provide 'ux/symbols)
;;; symbols.el ends here
