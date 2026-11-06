;;; sx.el --- Set up Stack Exchange for Emacs -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-sx-cache-directory*
 (path-join *user-cache-directory* "sx")
 "Path to user's Stack Exchange cache store.")

(use-package sx
  :commands sx-search
  :init
  (autoload 'sx-search "sx-load" nil t)
  (user/bind-key-global :apps :stack-exchange 'sx-search)
  ;; Set before sx-cache is loaded. The cache also holds the OAuth token,
  ;; which would otherwise be stored in `user-emacs-directory', so keep it
  ;; private.
  (setq sx-cache-directory *user-sx-cache-directory*)
  (make-directory *user-sx-cache-directory* t)
  (set-file-modes *user-sx-cache-directory* #o0700))


(provide 'apps/sx)
;;; sx.el ends here
