;;; pkg-config.el --- pkg-config support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun pkg-config-has-p (package)
  "Check if PACKAGE is available."
  (and (executable-find "pkg-config")
       (eq (call-process "pkg-config" nil nil nil "--exists" package) 0)))


(provide 'lib/pkg-config)
;;; pkg-config.el ends here
