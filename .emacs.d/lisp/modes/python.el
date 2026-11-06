;;; python.el --- initializes Python modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--python-mode-hook ()
  "Python mode hook."
  (user/tags-try-enable)

  ;; Enable smart parenthesis handling.
  (user/smartparens-enable)

  ;; Separate camel-case into separate words
  (subword-mode t)

  ;; ElDoc shows function documentation as you type
  (eldoc-mode t)

  ;; Enable LSP, if a language server is installed.
  (user/eglot-ensure)

  ;;; (Bindings) ;;;
  (when (feature-p 'pyvenv)
    (user/bind-key-local :code :virtual 'pyvenv-workon)))


(use-package python
  :if (or (executable-find "python3") (executable-find "python"))
  :defer
  :mode ("/SCon\\(struct\\|script\\)\\'" . python-mode)
  :interpreter ("python[0-9.]*" . python-mode)
  :hook
  ;; python-base-mode-hook also runs in python-ts-mode.
  (python-base-mode-hook . user--python-mode-hook)
  :config
  (validate-setq
   ;; Don't try to guess the indentation.
   python-indent-guess-indent-offset nil)

  (with-executable 'ipython3
    (validate-setq
     ;; Set IPython as default interpreter.
     python-shell-interpreter "ipython3"
     python-shell-interpreter-args ""
     python-shell-prompt-regexp "In \\[[0-9]+\\]: "
     python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
     python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
     python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n"
     python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n"))

  (with-executable 'bpython
    (defun user/bpython-term ()
      "Launch or switch to a `bpython' buffer."
      (interactive)
      (if (not (get-buffer "*bpython*"))
          (progn
            (ansi-term "bpython" "bpython"))
        (switch-to-buffer "*bpython*"))))

  ;;; (Packages) ;;;
  (use-package pyvenv
    :config
    ;; Enable virtualenv support. pyvenv-mode is a global minor mode.
    (pyvenv-mode t))

  (use-package pipenv
    :if (executable-find "pipenv")
    :hook (python-base-mode-hook . pipenv-mode))

  (use-package flycheck-pycheckers
    ;; The MELPA Stable release (0.16, 2018) fails to load in Emacs 30.
    :pin "MELPA"
    :after flycheck
    :hook (flycheck-mode-hook . flycheck-pycheckers-setup))
  (use-package flycheck-mypy
    :if (executable-find "mypy"))
  (use-package flycheck-prospector
    :if (executable-find "prospector")
    :hook (flycheck-mode-hook . flycheck-prospector-setup))

  (use-package helm-pydoc
    :pin "MELPA"))


(provide 'modes/python)
;;; python.el ends here
