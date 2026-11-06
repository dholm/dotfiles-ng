;;; eglot.el --- Language server protocol. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defvar-local user--eglot-ensured nil
  "Non-nil if Eglot has been requested for the current buffer.")


(defun user/eglot-server-available-p ()
  "Check if a language server is available for the current buffer."
  (when (and buffer-file-name
             (require 'eglot nil :noerror))
    ;; Resolve the server contact without prompting, the result is
    ;; (MANAGED-MODES PROJECT CLASS CONTACT LANG-IDS).
    (let ((contact (nth 3 (ignore-errors (eglot--guess-contact)))))
      (cond
       ;; No server configured for the current major mode.
       ((not (consp contact)) nil)
       ;; Connect to a running server using (HOST PORT ...).
       ((integerp (cadr contact)) t)
       ;; Spawn server using (PROGRAM ARGS ...), also on remote hosts.
       ((stringp (car contact))
        (executable-find (car contact) t))))))


(defun user/eglot-ensure ()
  "Start Eglot in the current buffer if a language server is available.
Return non-nil if the current buffer will be managed by Eglot."
  (or user--eglot-ensured
      (when (user/eglot-server-available-p)
        (eglot-ensure)
        (setq user--eglot-ensured t))))


(defun user/use-eglot ()
  "Check if the current buffer is managed by Eglot."
  (and (fboundp 'eglot-managed-p)
       (eglot-managed-p)))


(use-package eglot
  :ensure nil
  :defer
  :config
  (validate-setq
   ;; Don't log server communication, improves performance.
   eglot-events-buffer-config '(:size 0 :format full)
   ;; Increase the amount of data that can be read from a language server.
   read-process-output-max (* 3 1024 1024))

  ;; Don't watch files for changes, prevents freeze during compilation.
  (cl-defmethod eglot-client-capabilities :around (_server)
    (let ((capabilities (cl-call-next-method)))
      (plist-put (plist-get capabilities :workspace)
                 :didChangeWatchedFiles '(:dynamicRegistration :json-false))
      capabilities))

  ;;; (Packages) ;;;
  (use-package flycheck-eglot
    :after (flycheck)
    :config
    ;; Report diagnostics using Flycheck instead of Flymake.
    (global-flycheck-eglot-mode t)))


(provide 'utilities/eglot)
;;; eglot.el ends here
