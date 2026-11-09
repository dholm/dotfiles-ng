;;; paths.el --- Configure system paths in Emacs -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package exec-path-from-shell
  ;; A daemon started by systemd or the desktop also lacks the shell's PATH,
  ;; and `window-system' is nil while it starts.
  :if (or (daemonp) (memq window-system '(mac ns x)))
  :config
  (exec-path-from-shell-initialize))


(provide 'ux/paths)
;;; paths.el ends here
