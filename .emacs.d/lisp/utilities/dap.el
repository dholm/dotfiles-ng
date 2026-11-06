;;; dap.el --- Debug adapter protocol. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package dape
  :after (eglot)
  :bind-wrap
  (:map eglot-mode-map
        ((:key :debug :break) . dape-breakpoint-toggle)
        ((:key :debug :step) . dape-step-in)
        ((:key :debug :next) . dape-next)
        ((:key :debug :run) . dape)
        ((:key :debug :continue) . dape-continue)

        ((:key :debug :show-value) . dape-evaluate-expression))
  :config
  (validate-setq
   ;; Location of persistent breakpoints.
   dape-default-breakpoints-file (path-join *user-cache-directory* "dape-breakpoints"))

  ;; Persist breakpoints between sessions.
  (dape-breakpoint-load)
  (add-hook 'kill-emacs-hook #'dape-breakpoint-save))


(provide 'utilities/dap)
;;; dap.el ends here
