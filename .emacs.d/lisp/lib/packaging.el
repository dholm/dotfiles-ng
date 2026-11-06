;;; packaging.el --- initialize package management -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'lib/net)


(with-feature 'package
  (setq
   ;; Configure GNU/Emacs package repositories.
   package-archives
   '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
     ("MELPA Stable" . "https://stable.melpa.org/packages/")
     ("MELPA"        . "https://melpa.org/packages/"))
   ;; Prefer GNU ELPA over MELPA Stable over MELPA. GNU ELPA first, so
   ;; packages that are in both get the GNU ELPA release, which is usually
   ;; newer.
   package-archive-priorities
   '(("GNU ELPA"     . 20)
     ("MELPA Stable" . 15)
     ("MELPA"        . 10))))


;; Bootstrap `use-package'.
(package-initialize)
(unless (package-installed-p 'quelpa-use-package)
  (package-refresh-contents)
  (package-install 'quelpa-use-package))

(eval-when-compile
  ;; Load use-package.
  (require 'quelpa-use-package))

(use-package use-package
  :config
  (validate-setq
   use-package-always-ensure t
   ;; Hooks are verbatim.
   use-package-hook-name-suffix nil)

  (use-package quelpa-use-package
    :config
    (validate-setq
     ;; Only use quelpa for custom packages.
     quelpa-checkout-melpa-p nil
     ;; Only load quelpa on demand.
     quelpa-use-package-inhibit-loading-quelpa t)

    ;; Protect quelpa recipes when forcing ensure.
    (quelpa-use-package-activate-advice))

  ;; Support using keys from init-bindings by using (:key <group> <function>).
  (push :bind-wrap (cdr (member :bind use-package-keywords)))
  (push :bind*-wrap (cdr (member :bind* use-package-keywords)))
  (defun use-package-normalize-bind-wrap (name keyword args)
    (let ((arg args)
          args*)
      (while arg
        (let ((x (car arg)))
          (cond
           ;; ((:key :category :function) . COMMAND)
           ((and (consp x)
                 (consp (car x))
                 (equal (caar x) :key))
            (setq args* (nconc args*
                               (list (cons (apply 'user/get-key (cdar x))
                                     (cdar arg)))))
            (setq arg (cdr arg)))
           ;; (KEY . COMMAND)
           ((and (consp x)
                 (or (stringp (car x))
                     (vectorp (car x)))
                 (or (use-package-recognize-function (cdr x) t #'stringp)))
            (setq args* (nconc args* (list x)))
            (setq arg (cdr arg)))
           ;; Nested list.
           ((listp x)
            (setq args*
                  (nconc args* (use-package-normalize/:bind-wrap name keyword x)))
            (setq arg (cdr arg)))
           (t
            (setq args* (nconc args* (list x)))
            (setq arg (cdr arg))))))
      (use-package-normalize/:bind name keyword args*)))
  (defalias 'use-package-normalize/:bind-wrap 'use-package-normalize-bind-wrap)
  (defalias 'use-package-normalize/:bind*-wrap 'use-package-normalize-bind-wrap)
  ;; Create autoloads for the bound commands, like :bind does, so that the
  ;; keywords defer loading the package until a bound command is used.
  (defalias 'use-package-autoloads/:bind-wrap 'use-package-autoloads-mode)
  (defalias 'use-package-autoloads/:bind*-wrap 'use-package-autoloads-mode)
  (defun use-package-handler/:bind-wrap (name keyword arg rest state)
    (use-package-handler/:bind name keyword arg rest state))
  (defun use-package-handler/:bind*-wrap (name keyword arg rest state)
    (use-package-handler/:bind name keyword arg rest state 'bind-keys*))

  ;; Process :ensure after the :requires, :if, :when and :unless
  ;; conditions, like :quelpa, so that a package is only installed when
  ;; it is going to be configured.
  (let* ((keywords (remq :ensure use-package-keywords))
         (position (1+ (seq-position keywords :unless))))
    (setq use-package-keywords
          (append (seq-take keywords position)
                  '(:ensure)
                  (seq-drop keywords position)))))


(provide 'lib/packaging)
;;; packaging.el ends here
