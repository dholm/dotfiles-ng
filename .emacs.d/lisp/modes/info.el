;;; info.el --- Info mode. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--info-mode-hook ()
  "Info mode hook."
  (user/bind-key-local :nav :go-forward 'Info-history-forward)
  (user/bind-key-local :nav :go-back 'Info-history-back))

(use-package info
  :defer
  :hook (Info-mode-hook . user--info-mode-hook)
  :init
  (user/bind-key-global :emacs :describe-key-extensive
                        'Info-goto-emacs-key-command-node)
  (user/bind-key-global :emacs :manual 'info-emacs-manual)
  :config
  ;;; (Packages) ;;;
  (use-package niceify-info
    :defer
    :hook (Info-selection-hook . niceify-info))

  (use-package info-colors
    :defer
    :hook (Info-selection-hook . info-colors-fontify-node))

  (use-package helm-info
    :defer
    :ensure helm
    :bind (("C-c h h e" . helm-info-emacs)
           ("C-c h h i" . helm-info-at-point))))


(provide 'modes/info)
;;; info.el ends here
