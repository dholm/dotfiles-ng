;;; vc.el --- Emacs version control package support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--vc-find-file-hook ()
  "Find file hook for version controlled files."
  (with-feature 'vc
    (when (vc-working-revision (buffer-file-name))
      ;; Automatically refresh version controlled files.
      (auto-revert-mode t))))


(defun user--vc-log-edit-hook ()
  "Version control log editing hook."
  ;; Limited whitespace style and maximum line length. whitespace-mode is
  ;; already on from the text-mode hook, so restart it to apply them.
  (setq-local whitespace-style '(face lines-tail))
  (setq fill-column 72)
  (setq-local whitespace-line-column 72)
  (when (bound-and-true-p whitespace-mode)
    (whitespace-mode -1)
    (whitespace-mode 1))

  ;; Enable org minor mode editing tools.
  (orgtbl-mode t))

(use-package vc-annotate
  :ensure nil
  :defer
  :config
  (with-feature 'fullframe
    ;; Full frame annotations.
    (fullframe vc-annotate quit-window nil)))

(use-package autorevert
  :ensure nil
  :defer
  :diminish auto-revert-mode
  :config
  (with-eval-after-load 'tramp
    (validate-setq auto-revert-remote-files t)))

(add-hook 'find-file-hook 'user--vc-find-file-hook)
;; Commit messages written with VC (C-x v v). Magit's commit buffers run
;; the same hook through `user--git-commit-mode-hook'.
(add-hook 'log-edit-mode-hook 'user--vc-log-edit-hook)


(provide 'vcs/vc)
;;; vc.el ends here
