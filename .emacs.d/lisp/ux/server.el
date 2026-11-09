;;; server.el --- Emacs server setup -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/server-save ()
  "Save and quickly exit from server edit mode."
  (interactive)
  (save-buffer)
  (server-edit))


(defun user--server-after-init-hook ()
  "Initialize Emacs server after init has completed."
  (with-feature 'server
    ;; The daemon starts its server itself after init.
    (unless (or (daemonp) (server-running-p))
      (server-start)))

  ;; Edit-with-Emacs browser extension server. The daemon can show its
  ;; edit frames on graphical displays that are connected later. Starting
  ;; fails if the port is taken, which shouldn't abort `after-init-hook'.
  (when (and (or (daemonp) (display-graphic-p))
             (feature-p 'edit-server))
    (with-demoted-errors "Could not start edit-server: %S"
      (edit-server-start))))


(use-package server
  ;; Emacs clients regularly causes Emacs to crash on Darwin.
  :if (not (eq system-type 'darwin))
  :ensure nil
  :hook (after-init-hook . user--server-after-init-hook)
  :config
  (use-package edit-server
    :defer t))


(provide 'ux/server)
;;; server.el ends here
