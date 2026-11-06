;;; scala.el --- initializes Scala modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--scala-mode-hook ()
  "Scala mode hook."
  (user/smartparens-enable)

  ;; Enable LSP (Metals), if a language server is installed.
  (user/eglot-ensure))

(use-package scala-mode
  :if (executable-find "scala")
  :defer
  :init
  (add-hook 'scala-mode-hook 'user--scala-mode-hook))


(provide 'modes/scala)
;;; scala.el ends here
