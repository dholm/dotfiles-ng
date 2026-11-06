;;; gud.el --- Initializes GUD debugger -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--gud-mode-hook ()
  "GDB gud mode hook."
  (gud-tooltip-mode t)

  ;;; (Bindings) ;;;
  ;; Breakpoints
  (user/bind-key-local :debug :break 'gud-break)
  (user/bind-key-local :debug :break-temporary 'gud-tbreak)
  (user/bind-key-local :debug :watch 'gud-watch)

  ;; Stepping
  (user/bind-key-local :debug :step 'gud-step)
  (user/bind-key-local :debug :step-instruction 'gud-stepi)
  (user/bind-key-local :debug :next 'gud-next)

  ;; Execution
  (user/bind-key-local :debug :run 'gud-run)
  (user/bind-key-local :debug :continue 'gud-cont)
  (user/bind-key-local :debug :continue-stack 'gud-finish)
  (user/bind-key-local :debug :continue-until 'gud-until)

  ;; Stack frames
  (user/bind-key-local :debug :stack-up 'gud-up)
  (user/bind-key-local :debug :stack-down 'gud-down)

  ;; Printing
  (user/bind-key-local :debug :show-value 'gud-print))

(defun user--realgud-config ()
  "Bind the debugger keys in RealGud's debugger buffers."
  (dolist (binding
           '(;; Breakpoints
             (:break . realgud:cmd-break)
             (:watch . realgud:cmd-watch)
             ;; Stepping
             (:step . realgud:cmd-step)
             (:step-instruction . realgud:cmd-stepi)
             (:next . realgud:cmd-next)
             ;; Execution
             (:run . realgud:cmd-restart)
             (:continue . realgud:cmd-continue)
             (:continue-stack . realgud:cmd-finish)
             (:continue-until . realgud:cmd-until)
             ;; Stack frames
             (:stack-up . realgud:cmd-older-frame)
             (:stack-down . realgud:cmd-newer-frame)
             ;; Printing
             (:show-value . realgud:cmd-print)))
    (define-key realgud-track-mode-map
                (user/get-key :debug (car binding)) (cdr binding))))

(use-package gud
  :commands gud-gdb
  :hook (gud-mode-hook . user--gud-mode-hook)
  :config
  (validate-setq
   ;; Do not change the working directory before running inferior
   gud-chdir-before-run nil
   ;; Enable tooltips in gud mode
   gud-tooltip-mode t)

  (use-package gdb-mi
    :defer
    :config
    (validate-setq
     ;; Enable many windows
     gdb-many-windows t
     ;; Use a separate buffer for IO
     gdb-show-main t)))

(use-package realgud
  :defer
  :init
  ;; Start the debugger from C and Go buffers. The maps only exist once
  ;; their modes have loaded.
  (with-eval-after-load 'cc-mode
    (define-key c-mode-base-map (user/get-key :debug :start) #'realgud:gdb))
  (with-eval-after-load 'go-mode
    (define-key go-mode-map (user/get-key :debug :start) #'realgud-gub))
  :config
  (user--realgud-config)

  (use-package realgud-lldb
    :if (executable-find "lldb"))
  (use-package realgud-ipdb
    :if (executable-find "ipdb")))


(provide 'apps/gud)
;;; gud.el ends here
