;;; buffers.el --- Configure Emacs buffers -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/kill-all-buffers ()
  "Close all open buffers."
  (interactive)
  (mapc 'kill-buffer (buffer-list))
  (switch-to-buffer "*scratch*"))


(defun user/kill-other-buffers ()
  "Close all open buffers except current one."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))


(defun user--buffers-config ()
  "Initialize Emacs buffers."
  (use-package uniquify
    :ensure nil
    :config
    (validate-setq
     ;; Set up uniquify's style.
     uniquify-buffer-name-style 'reverse
     uniquify-separator " • "
     uniquify-after-kill-buffer-p t
     uniquify-ignore-buffers-re "^\\*"))

  ;;; (Bindings) ;;;
  (user/bind-key-global :basic :open-file 'find-file)
  (user/bind-key-global :basic :open-buffer 'switch-to-buffer)
  (user/bind-key-global :basic :save 'save-buffer)
  (user/bind-key-global :basic :save-as 'write-file)
  (user/bind-key-global :basic :close 'kill-buffer)
  (user/bind-key-global :basic :quit 'save-buffers-kill-terminal))

(user--buffers-config)


(provide 'ux/buffers)
;;; buffers.el ends here
