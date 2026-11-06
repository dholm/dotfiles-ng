;;; doxygen.el --- Doxygen mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defgroup doxygen nil "Support for Doxygen documentation."
  :group 'convenience)

(defvar doxygen-mode nil
  "Doxygen mode enabled when non-nil.")
(make-variable-buffer-local 'doxygen-mode)

(defcustom doxygen-mode-hook nil
  "Hook to run when `doxygen-mode' is turned on."
  :group 'doxygen
  :type '(hook))


(defun doxygen-mode (&optional arg)
  "Minor mode for Doxygen documentation, if ARG is nil the mode is toggled."
  (interactive "P")
  (setq doxygen-mode
        (if (null arg)
            (not doxygen-mode)
          (> (prefix-numeric-value arg) 0)))
  (when doxygen-mode
    (with-feature 'doxymacs
      (doxymacs-mode t))
    (run-hooks 'doxygen-mode-hook)))


(provide 'modes/doxygen)
;;; doxygen.el ends here
