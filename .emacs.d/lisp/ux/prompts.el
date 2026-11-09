;;; prompts.el --- Configure Emacs prompting -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--prompts-config ()
  "Initialize Emacs prompting."
  (validate-setq
   ;; Always follow links to version controlled files.
   vc-follow-symlinks t
   ;; Always ask before killing Emacs.
   confirm-kill-emacs 'y-or-n-p
   ;; Don't also ask about running processes when killing Emacs.
   confirm-kill-processes nil
   ;; Use shorter y/n prompts instead of yes/no.
   use-short-answers t
   ;; Don't use graphical dialog boxes when prompting. Harmless on
   ;; terminals, and graphical frames may only appear later (daemon).
   use-dialog-box nil))

(user--prompts-config)


(provide 'ux/prompts)
;;; prompts.el ends here
