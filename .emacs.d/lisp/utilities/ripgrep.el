;;; ripgrep.el --- interface to ripgrep -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package rg
  :if (executable-find "rg")
  :defer
  :config
  (use-package helm-rg))


(provide 'utilities/ripgrep)
;;; ripgrep.el ends here
