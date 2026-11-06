;;; utils.el --- miscellaneous support functions -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defmacro try-eval (fn &optional finally)
  "Evaluate FN, catching errors, and evaluate FINALLY afterwards.
Return the value of FN, or (exception ERROR) if FN signalled ERROR.
FINALLY is evaluated whether or not FN signalled an error."
  (declare (debug t)
           (indent 1))
  (let ((err (make-symbol "err")))
    `(unwind-protect
         (condition-case-unless-debug ,err
             ,fn
           (error (list 'exception ,err)))
       ,finally)))


(defun feature-p (feature)
  "Check if FEATURE is available."
  (or (featurep feature)
      (when (functionp 'package-installed-p)
        (package-installed-p feature))
      (locate-library (symbol-name feature))))


(defun add-command-switch (handler &rest switch-list)
  "Add HANDLER for SWITCH-LIST."
  (dolist (switch switch-list)
    (add-to-list 'command-switch-alist (cons switch handler))))


(defun add-auto-mode (mode &rest patterns)
  "Use `MODE' for all given files matching `PATTERNS'."
  (dolist (pattern patterns)
    (add-to-list 'auto-mode-alist (cons pattern mode))))


(defun add-magic-mode (mode &rest patterns)
  "Use `MODE' for all files containing header `PATTERNS'."
  (dolist (pattern patterns)
    (add-to-list 'magic-mode-alist (cons pattern mode))))


(defun add-interpreter-mode (mode &rest interpreters)
  "Use `MODE' for all files with shebang `INTERPRETERS'."
  (dolist (interpreter interpreters)
    (add-to-list 'interpreter-mode-alist (cons interpreter mode))))


(defun user--validate-value (symbol value)
  "Warn if SYMBOL is undefined or VALUE does not match its custom type.
Return VALUE."
  (cond
   ((not (boundp symbol))
    (display-warning
     'user (format "Setting `%s', which is not defined (yet)" symbol)))
   ((let ((type (get symbol 'custom-type)))
      (and type
           (not (condition-case nil
                    (widget-apply (widget-convert type) :match value)
                  ;; Don't complain about types the widget library can't check.
                  (error t)))))
    (display-warning
     'user (format "Value `%S' does not match the type of `%s'" value symbol))))
  value)


(defmacro validate-setq (&rest svs)
  "Like `setq', but warn about values that don't match their custom type.
Each SYM is set to VAL like `setq' does, so automatically buffer-local
variables are set in the current buffer.  A warning is displayed if
SYM is not defined yet or if VAL does not match the custom type of
SYM.  Unlike the `validate' package this never signals an error, so a
renamed variable or a changed type cannot abort the rest of a
configuration block.

\(fn [SYM VAL] ...)"
  (unless (zerop (% (length svs) 2))
    (error "`validate-setq' takes an even number of arguments"))
  (let (forms)
    (while svs
      (let ((symbol (pop svs))
            (value (pop svs)))
        (push `(setq ,symbol (user--validate-value ',symbol ,value)) forms)))
    `(progn ,@(nreverse forms))))


(provide 'lib/utils)
;;; utils.el ends here
