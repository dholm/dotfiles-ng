 ;;; google-services.el --- Support for Google services. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-google-services-data-directory*
  (path-join *user-data-directory* "google")
  "Path to user's Google services data store.")


(use-package oauth2
  :defer
  :config
  ;; Store OAuth2 tokens in the data store. Create the directory, since
  ;; the token file is only written on first use.
  (make-directory *user-google-services-data-directory* t)
  (set-file-modes *user-google-services-data-directory* #o0700)
  (validate-setq
   oauth2-token-file (path-join *user-google-services-data-directory*
                                "oauth2.plstore")))


(provide 'apps/google-services)
;;; google-services.el ends here
