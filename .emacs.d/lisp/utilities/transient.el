;;; transient.el --- Configuration for transient. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package transient
  :ensure nil
  :config
  ;; Using `validate-setq' here will cause loading to file if the
  ;; history file does not exist.
  (setq
   ;; Location of transient files. History is cache, the saved values and
   ;; levels are configuration.
   transient-history-file (path-join *user-cache-directory* "transient" "history.el")
   transient-values-file (path-join *user-data-directory* "transient" "values.el")
   transient-levels-file (path-join *user-data-directory* "transient" "levels.el"))

  ;; Create the transient folders.
  (make-directory (path-join *user-cache-directory* "transient") t)
  (make-directory (path-join *user-data-directory* "transient") t)

  ;; transient reads the files when it is loaded, which happens during
  ;; package activation (powerthesaurus's autoloads define a transient),
  ;; before this runs. Read them again from the paths set above.
  (when (fboundp 'transient--read-file-contents)
    (setq
     transient-values (transient--read-file-contents transient-values-file)
     transient-levels (transient--read-file-contents transient-levels-file)
     transient-history (transient--read-file-contents transient-history-file))))


(provide 'utilities/transient)
;;; transient.el ends here
