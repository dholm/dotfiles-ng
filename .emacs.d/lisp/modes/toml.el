;;; toml.el --- Initializes TOML mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--toml-mode-hook ()
  "Mode hook for TOML buffers."
  ;; conf-toml-mode derives from conf-mode and toml-ts-mode from
  ;; text-mode; set them up like code.
  (unless (derived-mode-p 'prog-mode)
    (user--prog-mode-hook)))


;; TOML files open in the built-in conf-toml-mode, or toml-ts-mode once
;; the grammar is installed.
(add-hook 'conf-toml-mode-hook 'user--toml-mode-hook)
(add-hook 'toml-ts-mode-hook 'user--toml-mode-hook)


(provide 'modes/toml)
;;; toml.el ends here
