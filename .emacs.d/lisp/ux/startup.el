;;; startup.el --- Configure Emacs startup behavior -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; startup.el has no `provide' statement.
(progn
  (validate-setq
   ;; Do not show the splash screen.
   inhibit-startup-screen t)

  ;; Do not show the startup message in the echo area. Setting
  ;; `inhibit-startup-echo-area-message' only works when it is set to
  ;; the literal user name in the init file itself.
  (advice-add 'display-startup-echo-area-message :override #'ignore)

  (use-package dashboard
    :config
    (dashboard-setup-startup-hook)))


(provide 'ux/startup)
;;; startup.el ends here
