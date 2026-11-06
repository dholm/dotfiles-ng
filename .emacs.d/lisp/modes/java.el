;;; java.el --- Java mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--java-mode-hook ()
  "Java mode hook."
  (user/eglot-ensure))

(use-package cc-mode
  :ensure nil
  :if (executable-find "javac")
  :defer
  :hook (java-mode-hook . user--java-mode-hook)
  :config
  (use-package mvn))


(provide 'modes/java)
;;; java.el ends here
