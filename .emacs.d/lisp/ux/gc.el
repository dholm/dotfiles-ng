;;; gc.el --- Garbage collector settings -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package gcmh
  :config
  (validate-setq
   ;; gcmh's default of 1 GiB between collections while busy lets the heap
   ;; grow large and makes the eventual collection pause long.
   gcmh-high-cons-threshold (* 128 1024 1024))
  (gcmh-mode t))


(provide 'ux/gc)
;;; gc.el ends here
