;;; javascript.el --- initializes JavaScript modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--javascript-mode-common-hook ()
  "JavaScript common mode hook."
  ;; Load CEDET
  (user--cedet-hook)

  (user/gnu-global-enable))


(defun user--javascript-mode-hook ()
  "JavaScript mode hook."
  ;; `js-mode-hook' also runs in modes derived from `js-mode', such as
  ;; `js2-mode' and `js-json-mode', which have their own hooks.
  (when (eq major-mode 'js-mode)
    (user--javascript-mode-common-hook)))


(defun user--inferior-js-mode-hook ()
  "Inferior JavaScript mode hook."
  ;; Support ANSI colors.
  (ansi-color-for-comint-mode-on))


(defun user--js2-mode-hook ()
  "JS2 mode hook."
  (user--javascript-mode-common-hook)
  ;; Enable smart indentation
  (smart-tabs-mode t)
  ;; Enable Flycheck
  (flycheck-mode t)
  ;; Enable LSP, if a language server is installed.
  (user/eglot-ensure))


(use-package js
  :defer
  :hook ((js-mode-hook . user--javascript-mode-hook)
         (inferior-js-mode-hook . user--inferior-js-mode-hook)))

(use-package js2-mode
  :defer
  :mode "\\.js\\'"
  :magic "#!/usr/bin/env node"
  :hook (js2-mode-hook . user--js2-mode-hook)
  :config
  (validate-setq
   ;; Disable error parsing in favor of Flycheck
   js2-strict-missing-semi-warning nil)
  (setq-default
   ;; Idle timeout before reparsing buffer, buffer-local in js2-mode.
   js2-idle-timer-delay 0.5)

  (with-executable 'node
    (use-package js-comint
      :defer
      :config
      (validate-setq
       ;; Set JavaScript inferior.
       js-comint-program-command (executable-find "node"))))

  (with-executable 'prettier
    (use-package prettier-js
      :defer)))


(provide 'modes/javascript)
;;; javascript.el ends here
