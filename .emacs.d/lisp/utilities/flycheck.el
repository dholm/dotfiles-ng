;;; flycheck.el --- flycheck configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--flycheck-mode-hook ()
  "Flycheck mode hook."
  ;;; (Bindings) ;;;
  (user/bind-key-local :code :warnings/errors 'helm-flycheck)
  (user/bind-key-local :nav :next 'flycheck-next-error))


(use-package flycheck
  :hook (flycheck-mode-hook . user--flycheck-mode-hook)
  :config
  (validate-setq
   ;; Wait five seconds before starting checker
   flycheck-idle-change-delay 5.0)

  (with-eval-after-load 'popwin
    ;; Use popwin for Flycheck error list.
    (push '(flycheck-error-list-mode :stick t) popwin:special-display-config))

  ;;; (Packages) ;;;
  (use-package flycheck-pos-tip
    :if window-system
    :config
    ;; Make sure flycheck-pos-tip is loaded.
    (require 'flycheck-pos-tip nil t))

  (use-package flycheck-indicator
    :hook (flycheck-mode-hook . flycheck-indicator-mode))

  (use-package helm-flycheck)

  (global-flycheck-mode t))


(provide 'utilities/flycheck)
;;; flycheck.el ends here
