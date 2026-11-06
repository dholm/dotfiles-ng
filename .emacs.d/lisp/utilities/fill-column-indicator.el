;;; fill-column-indicator.el --- shows the fill column -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package display-fill-column-indicator
  :ensure nil
  :defer
  :init
  (global-set-key [f3] 'display-fill-column-indicator-mode))


(provide 'utilities/fill-column-indicator)
;;; fill-column-indicator.el ends here
