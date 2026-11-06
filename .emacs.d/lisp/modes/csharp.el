;;; csharp.el --- C# mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-omnisharp-path*
  (path-join *user-home-directory* ".local" "opt" "omnisharp"))


(defun user--csharp-mode-hook ()
  "C# mode hook."
  (unless (derived-mode-p 'prog-mode)
    (user--prog-mode-hook))

  (with-executable 'xbuild
    (setq-local compile-command "xbuild "))

  ;; Still indent inside namespace.
  (c-set-offset 'innamespace '+)

  ;; Bring in CEDET.
  (user--cedet-hook)
  (with-feature 'omnisharp
    (eldoc-mode t)
    (add-ac-sources 'ac-source-omnisharp)
    (add-company-sources 'company-omnisharp)
    (omnisharp-mode t)))


(use-package csharp-mode
  :defer
  :init
  (add-hook 'csharp-mode-hook 'user--csharp-mode-hook)
  :config
  (use-package google-c-style
    :demand t
    :config
    ;; google-c-style only defines the style; register it under the name
    ;; that `c-default-style' refers to.
    (c-add-style "Google" google-c-style)
    (add-to-list 'c-default-style '(csharp-mode . "Google")))

  ;;; (Packages) ;;;
  (when (file-exists-p *user-omnisharp-path*)
    (use-package omnisharp
      :config
      (validate-setq
       omnisharp-server-executable-path
       (path-join *user-omnisharp-path* "omnisharp")))))


(provide 'modes/csharp)
;;; csharp.el ends here
