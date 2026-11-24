;;; yadm.el --- YADM support for Magit -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/yadm-status ()
  "Show the status of the yadm repository in Magit."
  (interactive)
  (magit-status "/yadm::"))


(with-executable 'yadm
  (with-eval-after-load 'tramp
    ;; yadm enter starts $SHELL. TRAMP has no login environment
    ;; parameter, so set it through env like TRAMP's sudo method does.
    (add-to-list 'tramp-methods
                 '("yadm"
                   (tramp-login-program "env")
                   (tramp-login-args (("SHELL=/bin/sh") ("yadm") ("enter")))
                   (tramp-remote-shell "/bin/sh")
                   (tramp-remote-shell-args ("-c"))))))


(provide 'utilities/yadm)
;;; yadm.el ends here
