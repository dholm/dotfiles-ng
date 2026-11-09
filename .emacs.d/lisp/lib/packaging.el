;;; packaging.el --- initialize package management -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'lib/net)


(with-feature 'package
  (setq
   ;; Configure GNU/Emacs package repositories.
   package-archives
   '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
     ("NonGNU ELPA"  . "https://elpa.nongnu.org/nongnu/")
     ("MELPA Stable" . "https://stable.melpa.org/packages/")
     ("MELPA"        . "https://melpa.org/packages/"))
   ;; Prefer GNU ELPA over NonGNU ELPA over MELPA Stable over MELPA. GNU
   ;; ELPA first, so packages that are in both get the GNU ELPA release,
   ;; which is usually newer.
   package-archive-priorities
   '(("GNU ELPA"     . 20)
     ("NonGNU ELPA"  . 18)
     ("MELPA Stable" . 15)
     ("MELPA"        . 10))))


;; Bootstrap `use-package'. Startup has normally activated the installed
;; packages before init.el is loaded, and then this does nothing; it is
;; needed when Emacs is started with -Q, as for basic.el. Don't use
;; `package-initialize', which also parses the index of every archive on
;; each start. The commands that install packages read the indexes when
;; they need them.
(package-activate-all)

(eval-when-compile
  (require 'use-package))

(use-package use-package
  :config
  (validate-setq
   use-package-always-ensure t
   ;; Hooks are verbatim.
   use-package-hook-name-suffix nil)

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
           ;; `user/get-key' returns a parsed key. Pass it as a vector,
           ;; since `bind-key' parses string keys again, which turns keys
           ;; containing C-l, TAB, C-j or SPC into different keys.
           ((and (consp x)
                 (consp (car x))
                 (equal (caar x) :key))
            (setq args* (nconc args*
                               (list (cons (vconcat
                                            (apply 'user/get-key (cdar x)))
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
  ;; conditions, like :vc, so that a package is only installed when it is
  ;; going to be configured.
  (let* ((keywords (remq :ensure use-package-keywords))
         (position (1+ (seq-position keywords :unless))))
    (setq use-package-keywords
          (append (seq-take keywords position)
                  '(:ensure)
                  (seq-drop keywords position))))

  ;; Pin packages without initializing package.el. The :pin keyword's
  ;; `use-package-pin-package' calls `package-initialize', which parses the
  ;; index of every archive, the first time a package is pinned. Pins only
  ;; matter when installing, and the install commands read the indexes
  ;; then.
  (defun user--use-package-pin-package (package archive)
    "Pin PACKAGE to ARCHIVE in `package-pinned-packages'."
    (let ((archive-name (if (stringp archive) archive (symbol-name archive))))
      (unless (assoc archive-name package-archives)
        (error "Archive '%s' requested for package '%s' is not available"
               archive-name package))
      (add-to-list 'package-pinned-packages (cons package archive-name))))
  (advice-add 'use-package-pin-package :override
              #'user--use-package-pin-package))


(provide 'lib/packaging)
;;; packaging.el ends here
