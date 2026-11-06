;;; package-menu.el --- Set up the package menu -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package package
  :ensure nil
  :defer
  :init
  (user/bind-key-global :apps :packages 'list-packages))


(provide 'apps/package-menu)
;;; package-menu.el ends here
