;;; syslog --- a mode for syslogs -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--syslog-mode-hook ()
  "Hook for syslog-mode."
  ;; There is no need to spell check log files.
  (flyspell-mode -1)

  ;;; (Bindings) ;;;
  (local-set-key (kbd "f") 'syslog-filter-lines)
  (local-set-key (kbd "F") 'hide-lines-show-all))

(use-package syslog-mode
  :defer
  ;; MELPA Stable only has 3.0, which calls the removed `toggle-read-only'.
  :pin "MELPA"
  ;; Log files and the text logs in /var/log, including rotated ones. Not
  ;; all of /var/log, which also holds binary files like wtmp and lastlog.
  :mode "\\(\\.log\\|/var/log/\\(syslog\\|messages\\|dmesg\\)\\)\\(\\.[0-9]+\\)?\\'"
  :init
  (add-hook 'syslog-mode-hook 'user--syslog-mode-hook))


(provide 'modes/syslog)
;;; syslog.el ends here
