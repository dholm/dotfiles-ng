;;; bootstrap.el --- Helpers for bootstrapping Emacs. -*- lexical-binding: t; -*-
;;; Commentary:

;; Stolen from Alexx Ott, https://github.com/alexott/dotemacs

;;; Code:

(defun load-all-files-from-dir (dir)
  "Load all Emacs Lisp files in DIR and its subdirectories.
Hidden directories, Emacs lock files (.#*) and bootstrapper.el are
skipped."
  (dolist (file (directory-files-recursively
                 dir "\\`[^.].*\\.el\\'" nil
                 (lambda (subdir)
                   (not (string-prefix-p "." (file-name-nondirectory subdir))))))
    (unless (string= "bootstrapper.el" (file-name-nondirectory file))
      (load-file file))))


(provide 'lib/bootstrap)
;;; bootstrap.el ends here
