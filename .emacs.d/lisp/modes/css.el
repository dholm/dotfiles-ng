;;; css --- initializes CSS modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--css-mode-hook ()
  "CSS mode hook."
  (setq-local
   ;; Indent using four spaces.
   css-indent-offset 4)

  (with-feature 'skewer-css
    (skewer-css-mode t))
  (with-feature 'rainbow-mode
    (rainbow-mode t))

  (when (memq major-mode '(css-mode css-ts-mode))
    ;; Only enable in strictly css-mode, not scss-mode (css-mode-hook
    ;; fires for scss-mode because scss-mode is derived from
    ;; css-mode).
    (user/eglot-ensure))

  ;;; (Bindings) ;;;
  (when (feature-p 'helm-css-scss)
    (user/bind-key-local :nav :functions/toc 'helm-css-scss)
    (user/bind-key-local :nav :go-back 'helm-css-scss-back-to-last-point)))


(use-package css-mode
  :defer
  :hook ((css-mode-hook css-ts-mode-hook) . user--css-mode-hook)
  :config
  (use-package rainbow-mode)

  (when (feature-p 'helm)
    (use-package helm-css-scss)))


(provide 'modes/css)
;;; css.el ends here
