;;; pdf.el --- Emacs PDF modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--pdf-view-mode-hook ()
  "PDF view mode hook."
  (user/bind-key-local :nav :goto-line 'pdf-view-goto-page))

(use-package pdf-tools
  ;; `window-system' is nil while the daemon starts, but its client frames
  ;; can be graphical.
  :if (and (or (daemonp) window-system) (pkg-config-has-p "poppler-glib"))
  :defer t
  :hook (pdf-view-mode-hook . user--pdf-view-mode-hook)
  :init
  ;; Load pdf-tools, and build epdfinfo if needed, when the first PDF is
  ;; opened instead of at startup.
  (pdf-loader-install)
  :config
  (use-package pdf-view
    :ensure nil
    :config
    (validate-setq
     ;; Fit page to view by default.
     pdf-view-display-size 'fit-page
     pdf-view-use-imagemagick t
     pdf-view-midnight-colors '("white smoke" . "gray5"))))


(provide 'modes/pdf)
;;; pdf.el ends here
