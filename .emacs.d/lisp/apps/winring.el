;;; winring.el --- Emacs window manager -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package winring
  :pin "MELPA"
  :defer t
  ;; Set up the ring for the initial frame once init is done.
  :hook (after-init-hook . winring-initialize)
  :config
  ;; `zoom-window-zoom' is autoloaded, so zoom-window loads when it's used.
  (define-key winring-map (kbd "z") 'zoom-window-zoom))

(use-package zoom-window
  :defer t)


(provide 'apps/winring)
;;; winring.el ends here
