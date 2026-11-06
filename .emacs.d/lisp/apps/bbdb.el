;;; bbdb.el --- Emacs rolodex -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-bbdb-database*
  (path-join *user-data-directory* "bbdb")
  "Path to user's BBDB file.")


(defun user/bbdb-create-or-update-notes ()
  "Decide how BBDB handles the addresses in the current message.
Create records, unless the message matches `bbdb-ignore-message-alist',
in which case only update existing records."
  (let ((ignored (eq bbdb-ignore-message-alist t)))
    (unless ignored
      (dolist (elt bbdb-ignore-message-alist)
        (dolist (header (if (stringp (car elt)) (list (car elt)) (car elt)))
          (when (bbdb-message-header-re header (cdr elt))
            (setq ignored t)))))
    (if ignored 'update 'create)))


(defun user/bbdb-display-record ()
  "Display appropriate BBDB record for the current message."
  (unless
      (bbdb-mua-display-records nil 'search)
    ;; No record found, close the BBDB popup
    (let ((window (get-buffer-window bbdb-buffer-name)))
      (when window (delete-window window)))))

(use-package bbdb
  :commands bbdb-initialize
  :defer
  :hook (bbdb-notice-mail-hook . bbdb-auto-notes)
  :config
  (validate-setq
   ;; Set up location of database.
   bbdb-file *user-bbdb-database*
   ;; Automatically save database without asking.
   bbdb-check-auto-save-file t
   ;; Try to fit popup horizontally.
   bbdb-mua-pop-up 'horiz
   ;; Size of popup.
   bbdb-mua-pop-up-window-size 2
   ;; Cycle through completions.
   bbdb-complete-mail-allow-cycling t
   ;; Hide pop-up after completion.
   bbdb-completion-display-record nil
   ;; Create records for the addresses in messages, see
   ;; `user/bbdb-create-or-update-notes'.
   bbdb-update-records-p 'user/bbdb-create-or-update-notes
   bbdb-mua-update-interactive-p '(create . create)
   ;; Don't assume a certain phone number style.
   bbdb-phone-style nil
   ;; Add all addresses in an email.
   bbdb-message-all-addresses t
   ;; Allow duplicate entries.
   bbdb-allow-duplicates t
   ;; Allow aliases.
   bbdb-add-aka t
   ;; Ignore certain addresses when adding to address book.
   bbdb-ignore-message-alist
   '(("From" . "no.*reply\\|DAEMON\\|daemon")))

  (setq
   ;; Fields to auto-populate in notes. Not validated: the rules use the
   ;; documented (HEADER (REGEXP FIELD STRING REPLACE)) form, which BBDB's
   ;; custom type doesn't describe.
   bbdb-auto-notes-rules
   (list
    '("Organization" (".*" organization "\\1" nil))
    '("Newsgroups" ("[^,]+" newsgroups identity nil))
    '("Xref" ("[^ ]+ \\([^ :]+\\):[0-9]+" newsgroups "\\1" nil))
    '("User-Agent" (".*" mailer identity nil))
    '("X-Mailer" (".*" mailer identity nil))
    '("X-Newsreader" (".*" mailer identity nil)))))


(provide 'apps/bbdb)
;;; bbdb.el ends here
