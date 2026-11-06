;;; diff.el --- Configure diff mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package diff-mode
  :defer
  :mode "/patch$"
  :config
  (validate-setq
   ;; Open patches in read-only mode by default.
   diff-default-read-only t))


(provide 'modes/diff)
;;; diff.el ends here
