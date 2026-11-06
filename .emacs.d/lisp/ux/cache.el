;;; cache.el --- Configure Emacs persistent caches -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package pcache
  :pin "MELPA"
  :init
  (setq-default
   ;; pcache appends repository names to this, so it must end in a slash.
   pcache-directory (file-name-as-directory
                     (path-join *user-cache-directory* "pcache"))))


(provide 'ux/cache)
;;; cache.el ends here
