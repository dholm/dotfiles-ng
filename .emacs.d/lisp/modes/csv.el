;;; csv --- initializes CSV modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--csv-mode-hook ()
  "CSV mode hook."
  (setq
   ;; Do not wrap long lines.
   truncate-lines t)

  (turn-off-auto-fill)
  (user/whitespace-disable-style '(lines)))

(declare-function csv-guess-set-separator "csv-mode")

(use-package csv-mode
  :defer
  :mode "\\.[Cc][Ss][Vv]$"
  :init
  (add-hook 'csv-mode-hook 'user--csv-mode-hook)
  ;; Use the separator the file actually uses (`,', `;' or TAB...). All
  ;; separators in `csv-separators' are active at the same time, so listing
  ;; space there would split "New York" into two fields.
  (add-hook 'csv-mode-hook #'csv-guess-set-separator)
  :config
  (validate-setq
   ;; Number of lines to consider part of header.
   csv-header-lines 1))


(provide 'modes/csv)
;;; csv.el ends here
