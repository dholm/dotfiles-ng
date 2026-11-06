;;; smtpmail.el --- Emacs SMTP -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-smtpmail-data-directory*
  (path-join *user-data-directory* "smtpmail")
  "Path to user's smtpmail data store.")

(defun user/smtpmail-set-gmail-user (_fullname username)
  "Configure smtpmail to send mail as USERNAME@gmail.com.
The password is read with auth-source, for example from a line like
\"machine smtp.gmail.com port 587 login USERNAME@gmail.com password
...\" in ~/.authinfo.gpg."
  (let ((email-address (concat username "@gmail.com")))
    (if (feature-p 'smtpmail-multi)
        (with-feature 'smtpmail-multi
          (let ((account (intern email-address)))
            ;; (ACCOUNT USER SERVER PORT MAIL-FROM STREAM-TYPE KEY CERT
            ;;  LOCAL-DOMAIN)
            (add-to-list 'smtpmail-multi-accounts
                         `(,account ,email-address "smtp.gmail.com" 587
                                    ,email-address starttls nil nil
                                    "gmail.com"))
            ;; Send mail from this address through the account.
            (add-to-list 'smtpmail-multi-associations
                         `(,(regexp-quote email-address) ,account))
            (unless smtpmail-multi-default-account
              (setq smtpmail-multi-default-account account))))
      (setq
       smtpmail-smtp-user email-address
       smtpmail-stream-type 'starttls
       smtpmail-default-smtp-server "smtp.gmail.com"
       smtpmail-smtp-server "smtp.gmail.com"
       smtpmail-smtp-service 587
       smtpmail-local-domain "gmail.com"
       mail-host-address "gmail.com"))))

(use-package smtpmail
  :defer
  :config
  (validate-setq
   ;; Location of send queue.
   smtpmail-queue-dir
   (path-join *user-smtpmail-data-directory* "send-queue")
   ;; Use smtpmail as the default method of sending email.
   send-mail-function 'smtpmail-send-it
   message-send-mail-function 'message-smtpmail-send-it)

  ;; Create directory for send queue.
  (make-directory smtpmail-queue-dir t)
  (set-file-modes smtpmail-queue-dir #o0700)

  (use-package smtpmail-multi
    :config
    (validate-setq
     ;; Use smtpmail-multi as the default method of sending email.
     send-mail-function 'smtpmail-multi-send-it
     message-send-mail-function 'smtpmail-multi-send-it))

  (use-package smtpmail-async
    :after async
    :ensure nil
    :config
    (validate-setq
     ;; Default to asynchronous mode.
     send-mail-function 'async-smtpmail-send-it
     message-send-mail-function 'async-smtpmail-send-it)))


(provide 'utilities/smtpmail)
;;; smtpmail.el ends here
