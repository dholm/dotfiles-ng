;;; php.el --- initializes PHP modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--php-mode-hook ()
  "PHP mode hook."
  ;; Bring in CEDET.
  (with-feature 'cedet
    (user--cedet-hook))

  (user/gnu-global-enable)
  (user/smartparens-enable)

  ;; Separate camel-case into separate words
  (subword-mode t))

(use-package php-mode
  :if (executable-find "php")
  :defer
  :init
  (with-eval-after-load 'web-mode
    (user--add-web-mode-hook 'php 'user--php-mode-hook)))


(provide 'modes/php)
;;; php.el ends here
