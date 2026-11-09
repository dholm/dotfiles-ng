;;; shell.el --- initializes shell modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--sh-mode-hook ()
  "Initialize mode for shell script editing."
  (validate-setq
   ;; Indent with four spaces.
   sh-basic-offset 4
   sh-indentation 4))


(defun user--shell-mode-common-hook ()
  "Shell mode common hook."
  (with-feature 'ansi-color
    ;; Enable ANSI colors for comint.
    (ansi-color-for-comint-mode-on))

  (with-feature 'shelldoc
    (shelldoc-minor-mode-on)))


(defun user--shell-mode-hook ()
  "Initialize mode for interactive shell."
  (user--shell-mode-common-hook))

(use-package shell
  :defer
  ;; sh-base-mode-hook also runs in bash-ts-mode.
  :hook ((sh-base-mode-hook . user--sh-mode-hook)
         (shell-mode-hook . user--shell-mode-hook))
  :config
  ;; Set when shell loads, before `shell' starts the first shell. Bash's
  ;; default arguments in Emacs (--noediting -i) and comint's own echo
  ;; handling are used; `comint-process-echoes' would also apply to every
  ;; other comint mode and make Emacs wait for echoes that don't come.
  (validate-setq
   explicit-shell-file-name "bash")

  ;;; (Packages) ;;;
  ;; shell is loaded during startup (by helm-mode), so defer the packages
  ;; that are only needed in shell and script buffers.
  (use-package bash-completion
    :defer t)
  (use-package company-shell
    :after (company)
    :config
    (add-to-list 'company-backends '(company-shell company-shell-env)))
  (use-package shelldoc
    :defer t)
  (use-package flycheck-checkbashisms
    :if (executable-find "checkbashisms")
    :defer t
    :hook (sh-base-mode-hook . flycheck-checkbashisms-setup))
  (use-package flycheck-bashate
    :if (executable-find "bashate")
    :defer t
    :hook (sh-base-mode-hook . flycheck-bashate-setup)))


(provide 'modes/shell)
;;; shell.el ends here
