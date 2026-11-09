;;; elisp.el --- Initializes Emacs Lisp modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--emacs-lisp-mode-hook ()
  "Emacs Lisp mode hook."
  (when (fboundp 'user--lisp-mode-common-hook)
    (user--lisp-mode-common-hook))

  (with-feature 'auto-compile
    (auto-compile-on-save-mode t)
    (auto-compile-on-load-mode t))

  (with-feature 'eros
    (eros-mode t))

  (when (user/company-mode-p)
    (with-feature 'company-elisp
      (add-company-sources 'company-elisp)))

  ;;; (Bindings) ;;;
  (with-feature 'popwin
    (user/bind-key-local :util :popwin-messages 'popwin:messages))

  (with-feature 'macrostep
    (user/bind-key-local :code :macro-expand 'macrostep-expand))

  (user/bind-key-local :doc :reference 'elisp-index-search)
  (user/bind-key-local :doc :describe 'user/elisp-describe-thing-in-popup)
  (user/bind-key-local :doc :describe-function 'describe-function)
  (user/bind-key-local :doc :describe-variable 'describe-variable)

  (user/bind-key-local :debug :start 'debug)
  (user/bind-key-local :debug :break 'edebug-defun)
  (user/bind-key-local :debug :trace 'trace-function-background)
  (user/bind-key-local :debug :continue 'debugger-continue)
  (user/bind-key-local :debug :step 'debugger-step-through))


(defun user--elisp-flycheck-mode-hook ()
  "Add the extra Emacs Lisp checkers when Flycheck first checks an Elisp file.
Loading them, package-lint in particular, is slow, so it waits until
they are needed instead of happening at startup or in *scratch*."
  (when (and (derived-mode-p 'emacs-lisp-mode) buffer-file-name)
    (remove-hook 'flycheck-mode-hook #'user--elisp-flycheck-mode-hook)
    ;; flycheck-relint links to the package checker if it exists, so set
    ;; up flycheck-package first.
    (dolist (setup '(flycheck-elsa-setup
                     flycheck-package-setup
                     flycheck-relint-setup))
      (when (fboundp setup)
        (funcall setup)))))


(defun user--ielm-mode-hook ()
  "Interactive Emacs Lisp mode hook."
  (user--emacs-lisp-mode-hook))


(defvar paredit-mode-map)

(defun user--minibuffer-setup-hook ()
  "Emacs minibuffer hook."
  (when (eq this-command 'eval-expression)
    (when (feature-p 'rainbow-delimiters)
      (rainbow-delimiters-mode))
    (when (feature-p 'paredit)
      (enable-paredit-mode)
      ;; Paredit binds RET and C-j to insert newlines, keep them submitting
      ;; the expression.
      (let ((map (make-sparse-keymap)))
        (set-keymap-parent map paredit-mode-map)
        (define-key map (kbd "RET") #'exit-minibuffer)
        (define-key map (kbd "C-j") #'exit-minibuffer)
        (setq-local minor-mode-overriding-map-alist
                    (cons (cons 'paredit-mode map)
                          (assq-delete-all 'paredit-mode
                                           (copy-sequence
                                            minor-mode-overriding-map-alist))))))))


(defun user/elisp-describe-thing-in-popup ()
  "Describe elisp thing at point in a popup."
  (interactive)
  (with-feature 'popup
    (let* ((thing (symbol-at-point))
           (help-xref-following t)
           (description (with-temp-buffer
                          (help-mode)
                          (describe-symbol thing)
                          (buffer-string))))
      (popup-tip description
                 :point (point)
                 :around t
                 :height 30
                 :scroll-bar t
                 :margin t))))

(use-package elisp-mode
  :ensure nil
  :mode ("Carton$" . emacs-lisp-mode)
  :init
  (add-hook 'emacs-lisp-mode-hook 'user--emacs-lisp-mode-hook)
  (add-hook 'minibuffer-setup-hook 'user--minibuffer-setup-hook)
  (add-hook 'flycheck-mode-hook #'user--elisp-flycheck-mode-hook)
  :config
  ;; elisp-mode is preloaded, so this :config runs at startup. The packages
  ;; below are deferred; the hooks load them when they are used.
  (use-package ielm
    :defer t
    :init
    (add-hook 'ielm-mode-hook 'user--ielm-mode-hook))

  ;;; (Packages) ;;;
  (use-package macrostep
    :defer t)
  (use-package edebug-inline-result
    :ensure t
    :defer t
    :custom (edebug-inline-result-backend 'posframe)
    :hook (edebug-mode-hook . edebug-inline-result-mode))
  (use-package eros
    :defer t
    :config
    (when (eq default-terminal-coding-system 'utf-8)
      (validate-setq
       eros-eval-result-prefix "∴ ")))
  (use-package flycheck-elsa
    :defer t)
  (use-package auto-compile
    :defer t)
  (use-package rainbow-delimiters
    :defer t)
  (use-package paredit
    :defer t
    :diminish paredit-mode)
  (use-package helm-elisp
    :ensure helm
    :bind (("C-c h a" . helm-apropos)
           ("C-c h l" . helm-locate-library))
    :config
    (validate-setq
     helm-apropos-fuzzy-match t
     helm-lisp-fuzzy-completion t))
  (use-package flycheck-package
    :defer t)
  (use-package flycheck-relint
    :defer t)
  (use-package fontify-face
    :hook (emacs-lisp-mode-hook . fontify-face-mode))
  (use-package elpl
    :bind-wrap
    ((:key :code :repl) . elpl))
  (use-package describe-hash
    :defer t))


(provide 'modes/elisp)
;;; elisp.el ends here
