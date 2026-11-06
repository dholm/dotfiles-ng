;;; swig.el --- SWIG mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package swig-mode
  :defer
  ;; package-vc can only install this once the Version header of
  ;; swig-mode.el, an RCS $Id$ string, is a version number.
  :vc (:url "https://github.com/dholm/swig-mode")
  :mode "\\.swg$")


(provide 'modes/swig)
;;; swig.el ends here
