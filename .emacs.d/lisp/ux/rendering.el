;;; rendering.el --- Configure Emacs user interface rendering -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-fast-font-lock-buffer-limit* (* 128 1024)
  "Maximum buffer size for maximum font lock decorations.")


(defun user--rendering-find-file-hook ()
  "Rendering hook for `find-file'."
  (when (> (buffer-size) *user-fast-font-lock-buffer-limit*)
    (setq-local
     ;; Reduce the level of fontification.
     font-lock-maximum-decoration nil)

    (font-lock-refresh-defaults)))


(defun user--rendering-config ()
  "Setup Emacs user interface rendering."
  (validate-setq
   ;; Use the maximum amount of decorations by default.
   font-lock-maximum-decoration t
   ;; Always use JIT mode for font-lock.
   font-lock-support-mode 'jit-lock-mode
   ;; Set up font-lock JIT mode to do background parsing.
   jit-lock-stealth-time 1.0
   jit-lock-stealth-nice 0.03
   jit-lock-stealth-load 200
   jit-lock-stealth-verbose nil
   jit-lock-chunk-size 500
   ;; Don't look for bidirectional parentheses, which is slow in long
   ;; lines.
   bidi-inhibit-bpa t)

  (setq-default
   ;; Lay out all paragraphs left to right instead of detecting their
   ;; direction, which saves work in redisplay.
   bidi-paragraph-direction 'left-to-right)

  ;;; (Hooks) ;;;
  (add-hook 'find-file-hook 'user--rendering-find-file-hook)

  ;;; (Bindings) ;;;
  (user/bind-key-global :emacs :redraw 'redraw-display))

(user--rendering-config)


(provide 'ux/rendering)
;;; rendering.el ends here
