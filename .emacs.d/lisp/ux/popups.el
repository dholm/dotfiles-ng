;;; popups.el --- Configure Emacs popups -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--popups-config ()
  "Initialize Emacs popups."
  (validate-setq
   ;; Timeout for messages shown in minibuffer.
   minibuffer-message-timeout 5)

  ;;; (Packages) ;;;
  (use-package popup
    :config
    ;; Install workaround for whitespace-mode bug.
    (with-eval-after-load 'modes/whitespace
      (define-advice popup-draw (:before (&rest _) user-turn-off-whitespace)
        "Turn off whitespace mode before showing popup."
        (user/whitespace-mode-suppress t))

      (define-advice popup-delete (:after (&rest _) user-restore-whitespace)
        "Restore previous whitespace mode when deleting popup."
        (user/whitespace-mode-suppress nil))))

  (use-package popwin
    :init
    (user/bind-key-global :util :popwin-close 'popwin:close-popup-window)
    (user/bind-key-global :util :popwin-buffer 'popwin:popup-buffer)
    :config
    (popwin-mode t)))

(user--popups-config)


(provide 'ux/popups)
;;; popups.el ends here
