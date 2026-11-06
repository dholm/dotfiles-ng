;;; cheat-sh.el --- Look up topics on cheat.sh -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package cheat-sh
  :defer
  :init
  (user/bind-key-global :apps :cheat-sh 'cheat-sh)
  :config
  ;; Look topics up over HTTPS instead of HTTP.
  (setq cheat-sh-url "https://cheat.sh/%s?T"))


(provide 'apps/cheat-sh)
;;; cheat-sh.el ends here
