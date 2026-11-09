;;; mustache.el --- Mustache template mode support. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package mustache-mode
  ;; The package only registers its file name pattern when it is loaded.
  :mode "\\.mustache\\'")


(provide 'modes/mustache)
;;; mustache.el ends here
