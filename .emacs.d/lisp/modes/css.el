;;; css --- initializes CSS modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--css-mode-hook ()
  "CSS mode hook."
  (setq-local
   ;; Indent using four spaces.
   css-indent-offset 4)

  (with-feature 'showcss-mode
    (showcss-mode t))
  (with-feature 'skewer-css
    (skewer-css-mode t))
  (with-feature 'rainbow-mode
    (rainbow-mode t))

  (when (eq major-mode 'css-mode)
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
  :hook (css-mode-hook . user--css-mode-hook)
  :config
  (use-package showcss-mode
    :quelpa (showcss-mode
             :fetcher github
             :repo "smmcg/showcss-mode"))

  (use-package rainbow-mode)

  (when (feature-p 'helm)
    (use-package helm-css-scss))

  (use-package flycheck-css-colorguard
    :config
    (flycheck-css-colorguard-setup))

  (use-package css-autoprefixer
    :if (executable-find "npx")))


(provide 'modes/css)
;;; css.el ends here
