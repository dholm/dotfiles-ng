;;; tags.el --- Helpers for working with tags -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/use-helm-gtags ()
  "Check if helm-gtags can be used."
  (when (boundp 'helm-gtags-mode)
    helm-gtags-mode))


(defun user/use-semantic ()
  "Check if semantic can be used."
  (and (fboundp 'semantic-mode)
       semantic-mode))


(defun user/use-go-guru ()
  "Check if Go guru can be used."
  (executable-find "guru"))


(defun user/eval-until-move (cond-list)
  "Evaluate expressions from COND-LIST until point is changed."
  (let ((start-buffer (current-buffer))
        (start-point (point)))
    (dolist (cond-expr cond-list)
      (when (and (eq start-buffer (current-buffer))
                 (eq start-point (point)))
        (let ((cnd (car cond-expr))
              (expr (cadr cond-expr)))
          (when (eval cnd)
            (eval expr)))))))


(defun user/tag-update-index ()
  "Update tag index backend(s)."
  (interactive)
  (user/gnu-global-create/update))


(defun user/tag-toc ()
  "Show table of contents for current context."
  (interactive)
  (user/eval-until-move
   '(((or (user/use-helm-gtags) (user/use-semantic))
      (call-interactively 'helm-semantic-or-imenu))
     (t (call-interactively 'helm-imenu)))))


(defun user/tag-follow ()
  "Follow tag at point using best available method."
  (interactive)
  (user/eval-until-move
   '(((user/use-eglot)
      (let ((xref-prompt-for-identifier nil))
        (call-interactively 'xref-find-definitions)))

     ((bound-and-true-p elisp-def-mode)
      (call-interactively 'elisp-def))
     ((derived-mode-p 'emacs-lisp-mode)
      (let ((xref-prompt-for-identifier nil))
        (call-interactively 'xref-find-definitions)))

     ((eq major-mode 'go-mode)
      (when (user/use-go-guru)
        (call-interactively 'go-guru-definition)))

     ((user/use-helm-gtags)
      (call-interactively 'helm-gtags-dwim))
     ((user/use-semantic)
      (call-interactively 'semantic-ia-fast-jump)))))


(defun user/tag-references-at-point ()
  "Find references at current point."
  (interactive)
  (user/eval-until-move
   '(((user/use-eglot)
      (let ((xref-prompt-for-identifier nil))
        (call-interactively 'xref-find-references)))

     ((eq major-mode 'go-mode)
      (when (user/use-go-guru)
        (call-interactively 'go-guru-referrers)))

     ((user/use-helm-gtags)
      (call-interactively 'helm-gtags-find-rtag))
     ((user/use-semantic)
      (call-interactively 'semantic-symref)))))


(defun user/tag-find ()
  "Find tag by name."
  (interactive)
  (user/eval-until-move
   '(((user/use-eglot)
      (call-interactively 'xref-find-apropos))
     ((user/use-helm-gtags)
      (call-interactively 'helm-gtags-select))
     ((user/use-semantic)
      (call-interactively 'semantic-symref-find-tags-by-regexp)))))


(defun user/tag-find-references ()
  "Find references to tag."
  (interactive)
  (user/eval-until-move
   '(((user/use-eglot)
      (let ((xref-prompt-for-identifier nil))
        (call-interactively 'xref-find-references)))

     ((eq major-mode 'go-mode)
      (when (user/use-go-guru)
        (call-interactively 'go-guru-callers)))

     ((user/use-helm-gtags)
      (call-interactively 'helm-gtags-find-rtag))
     ((user/use-semantic)
      (call-interactively 'semantic-symref-regexp)))))


(defun user/tag-describe ()
  "Describe the tag."
  (interactive)
  (cond
   ;; Interactive ElDoc also shows the documentation buffer.
   ((user/use-eglot) (call-interactively 'eldoc))
   ((eq major-mode 'go-mode)
    (when (user/use-go-guru)
      (call-interactively 'go-guru-describe)))
   ((user/use-semantic) (call-interactively 'semantic-ia-show-doc))))


(defun user/tag-rename ()
  "Rename the tag."
  (interactive)
  (cond
   ((user/use-eglot) (call-interactively 'eglot-rename))
   ((eq major-mode 'go-mode)
    (if (executable-find "godoctor")
        (call-interactively 'godoctor-rename)
      (call-interactively 'go-rename)))))


(defun user/tag-find-file ()
  "Find file file using tags."
  (interactive)
  (user/eval-until-move
   '(((user/use-helm-gtags)
      (call-interactively 'helm-gtags-select-path))
     ((fboundp 'projectile-find-file)
      (call-interactively 'projectile-find-file)))))


(defun user/tag-pop ()
  "Return to the previous point before jump."
  (interactive)
  (user/eval-until-move
   '(((user/use-eglot)
      (call-interactively 'xref-go-back))

     ((eq major-mode 'go-mode)
      (when (user/use-go-guru)
        (pop-global-mark)))

     ((user/use-helm-gtags)
      (call-interactively 'helm-gtags-pop-stack))
     (t (pop-global-mark)))))


(defun user/tags-try-enable ()
  "Enable tags if any of the tag backends is located."
  (when (or (user/eglot-ensure)
            (user/use-helm-gtags)
            (user/use-semantic))
    ;;; (Bindings) ;;;
    (user/bind-key-local :code :update-index 'user/tag-update-index)
    (user/bind-key-local :nav :functions/toc 'user/tag-toc)
    (user/bind-key-local :nav :follow-symbol 'user/tag-follow)
    (user/bind-key-local :nav :find-symbol 'user/tag-find)
    (user/bind-key-local :nav :references 'user/tag-references-at-point)
    (user/bind-key-local :doc :describe 'user/tag-describe)
    (user/bind-key-local :code :refactor-rename 'user/tag-rename)
    (user/bind-key-local :nav :find-references 'user/tag-find-references)
    (user/bind-key-local :basic :open-file-context 'user/tag-find-file)
    (user/bind-key-local :nav :go-back 'user/tag-pop)))

(use-package elisp-def
  :hook ((emacs-lisp-mode-hook . elisp-def-mode)
         (ielm-mode-hook . elisp-def-mode)))

;; helm-xref's autoloads set `xref-show-xrefs-function' and
;; `xref-show-definitions-function', so it only needs to be installed.
(use-package helm-xref
  :defer t)


(provide 'utilities/tags)
;;; tags.el ends here
