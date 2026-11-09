;;; theme.el --- Configure Emacs theme -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--theme-graphic-frame-hook ()
  "Load the theme again for the first graphical client frame.
The theme picks its palette from the selected frame when it is loaded.
Under the daemon that happens before any frame has a display, which
selects the 256-color palette. The graphical palette also works in
terminal frames, where Emacs maps the colors to the nearest ones."
  (when (display-graphic-p)
    (remove-hook 'server-after-make-frame-hook #'user--theme-graphic-frame-hook)
    (load-theme 'solarized-dholm t)))


(use-package custom
  :ensure nil
  :config
  (use-package solarized-dholm-theme
    :vc (:url "https://github.com/dholm/solarized-theme")
    :config
    (setq
     ;; Make the fringe stand out.
     solarized-distinct-fringe-background t)

    (load-theme 'solarized-dholm t)
    (when (daemonp)
      (add-hook 'server-after-make-frame-hook #'user--theme-graphic-frame-hook))))

(use-package faces
  :ensure nil
  :defer
  :bind-wrap
  (((:key :emacs :describe-face) . describe-face)
   ((:key :emacs :describe-all-faces) . list-faces-display))
  :config
  ;; Not tied to `display-graphic-p', which is nil under the daemon. With a
  ;; nil frame this also sets the default for frames created later, such as
  ;; emacsclient frames. The size is adjusted per frame by textsize below.
  (pcase system-type
    ('darwin
     (set-face-attribute 'default nil :family "Menlo" :height 110 :weight 'normal))
    ('windows-nt
     (set-face-attribute 'default nil :family "Consolas" :height 100 :weight 'normal))
    ('gnu/linux
     (set-face-attribute 'default nil :foundry "bitstream" :family "Meslo LG S DZ"
                         :height 74 :weight 'normal)))

  (use-package textsize
    :commands textsize-mode
    :bind-wrap
    (((:key :emacs :text-scale-reset) . textsize-reset)
     ((:key :emacs :text-scale-increase) . textsize-increment)
     ((:key :emacs :text-scale-decrease)  . textsize-decrement))
    :init (textsize-mode)
    :config
    (validate-setq
     textsize-default-points 11)))

(use-package ns-auto-titlebar
  :if (eq system-type 'darwin)
  :config
  (ns-auto-titlebar-mode))


(provide 'ux/theme)
;;; theme.el ends here
