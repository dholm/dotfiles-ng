;;; ttcn.el --- initializes TTCN modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--ttcn3-mode-hook ()
  "TTCN mode hook."
  ;; Separate camel-case into separate words
  (subword-mode t))

(use-package ttcn-mode
  :defer
  ;; package-vc can only install this once the Version header of ttcn.el,
  ;; an RCS $Id$ string, is a version number.
  :vc (:url "https://github.com/dholm/ttcn-el"
       :main-file "ttcn.el")
  :mode (("\\.mp$" . ttcn-mode)
         ("\\.ttcn3?\\'" . ttcn-3-mode))
  :init
  ;; The package has no ttcn-mode feature, so :config would never run.
  (add-hook 'ttcn3-mode-hook 'user--ttcn3-mode-hook))


(provide 'modes/ttcn)
;;; ttcn.el ends here
