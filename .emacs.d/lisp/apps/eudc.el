;;; eudc.el --- Configure the Emacs Unified Directory Client -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/eudc-expand-inline ()
  "Expand entry at point using EUDC."
  (interactive)
  (let ((tick (buffer-chars-modified-tick)))
    (cond
     ((eq eudc-protocol 'ldap)
      (progn
        (unless (condition-case nil
                    (eudc-expand-inline)
                  (error nil)))))
     (t (eudc-expand-inline)))
    ;; Remove the metadata that the LDAP expansion format appends after the
    ;; address. Only touch the text just inserted before point, and only if
    ;; an expansion actually took place.
    (when (and (/= tick (buffer-chars-modified-tick))
               (looking-back " {[^{}\n]*}" (line-beginning-position)))
      (replace-match ""))))


(use-package eudc
  :defer
  :config
  (validate-setq
   ;; Only return default attributes for current server.
   eudc-default-return-attributes nil
   ;; Do not ignore incomplete results.
   eudc-strict-return-matches nil
   ;; Server hotlist store.
   eudc-options-file (path-join *user-cache-directory* "eudc-options"))

  (with-eval-after-load 'ldap
    (validate-setq
     ;; Default `ldapsearch' parameters. -ZZ requires StartTLS, so the
     ;; simple bind (-x) never sends the password in cleartext. For servers
     ;; without StartTLS, use an ldaps:// host instead.
     ldap-ldapsearch-args '("-tt" "-LLL" "-x" "-ZZ"))

    ;; Treat the displayName attribute as a string.
    (add-to-list 'ldap-attribute-syntaxes-alist '(displayname . 15))

    (eudc-protocol-set
     'eudc-inline-expansion-format
     '("%s <%s> {%s %s}" displayname email company department)
     'ldap)
    (eudc-protocol-set
     'eudc-inline-query-format
     '((cn) (mail) (cn cn) (cn cn cn) (sn) (uid) (givenname) (givenname name) (name))
     'ldap))

  (with-eval-after-load 'bbdb
    (eudc-protocol-set
     'eudc-inline-expansion-format
     '("%s %s <%s>" firstname lastname net)
     'bbdb)
    (eudc-protocol-set
     'eudc-inline-query-format
     '((name) (firstname) (lastname) (firstname lastname))
     'bbdb)

    ;; Default to BBDB.
    (eudc-set-server "localhost" 'bbdb t)
    (add-to-list 'eudc-server-hotlist '("localhost" . bbdb))))


(provide 'apps/eudc)
;;; eudc.el ends here
