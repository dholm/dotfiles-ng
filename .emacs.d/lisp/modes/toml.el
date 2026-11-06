;;; toml.el --- Initializes TOML mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--toml-mode-hook ()
  "Mode hook for TOML buffers."
  ;; toml-mode derives from conf-mode; set it up like code.
  (unless (derived-mode-p 'prog-mode)
    (user--prog-mode-hook)))


(use-package toml-mode
  :config
  (add-hook 'toml-mode-hook 'user--toml-mode-hook))


(provide 'modes/toml)
;;; toml.el ends here
