;;; hash-tables.el --- utilities for working with LISP hash tables -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; For `hash-table-keys'.
(require 'subr-x)


(defun hash-table-to-list (hash-table)
  "Return a list that represent the HASH-TABLE."
  (let (ll)
    (maphash (lambda (kk vv) (setq ll (cons (list kk vv) ll))) hash-table)
    ll))

(cl-defmacro do-hash-table-sorted-by-value ((x hash-table) &rest body)
  "Iterates over keys in HASH-TABLE sorted by value with keys accessible as X
to BODY."
  (declare (indent defun))
  `(dolist (,x (sort (hash-table-keys ,hash-table)
                     (lambda (k1 k2)
                       (< (gethash k1 ,hash-table)
                          (gethash k2 ,hash-table)))))
     ,@body))


(provide 'lib/hash-tables)
;;; hash-tables.el ends here
