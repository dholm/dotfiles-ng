;;; vhdl.el --- VHDL mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--vhdl-mode-hook ()
  "VHDL mode hook."
  (user/gnu-global-enable))

(use-package vhdl-mode
  ;; Use the version that comes with Emacs.
  :ensure nil
  :defer
  :mode "\\.vhdl?$"
  :init
  (add-hook 'vhdl-mode-hook 'user--vhdl-mode-hook))


(provide 'modes/vhdl)
;;; vhdl.el ends here
