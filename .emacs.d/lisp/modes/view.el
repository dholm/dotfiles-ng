;;; view.el --- Emacs view mode setup -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package view
  :defer
  :init
  ;; Set before view is loaded: files.el checks it when visiting files.
  (validate-setq
   ;; Open read-only files in view-mode by default.
   view-read-only t))


(provide 'modes/view)
;;; view.el ends here
