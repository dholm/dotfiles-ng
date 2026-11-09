;;; git.el --- Git integration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--git-commit-mode-hook ()
  "Git commit mode hook."
  ;; Run the shared log edit hook.
  (user--vc-log-edit-hook))


(defun user/magit-toggle-whitespace ()
  "Toggle showing all differences in whitespace when using Magit."
  (interactive)
  (if (seq-intersection '("-w" "--ignore-all-space") magit-buffer-diff-args)
      (progn
        (message "Showing differences in whitespace.")
        (setq magit-buffer-diff-args
              (seq-difference magit-buffer-diff-args
                              '("-w" "--ignore-all-space"))))
    (progn
      (message "Hiding differences in whitespace.")
      (push "-w" magit-buffer-diff-args)))
  (magit-refresh))


(defun user--git-config ()
  "Initialize Git support."
  ;; git-modes associates the usual names; also open the local variants
  ;; and the core excludes file in its modes.
  (add-auto-mode 'gitconfig-mode "/\\.gitconfig\\.local\\'")
  (add-auto-mode 'gitignore-mode "/\\.gitignore\\.\\(local\\|core\\)\\'")
  (add-auto-mode 'gitattributes-mode "/\\.gitattributes\\.local\\'")

  (use-package git-commit
    :ensure nil
    :hook (git-commit-mode-hook . user--git-commit-mode-hook)
    :bind-wrap
    (:map git-commit-mode-map
          ((:key :basic :server-edit) . with-editor-finish)))

  (use-package magit
    :defer
    :config
    (validate-setq
     ;; Automatically show process buffer if git takes too long to execute.
     magit-process-popup-time 30
     ;; Show fine differences for currently selected hunk.
     magit-diff-refine-hunk t)

    (with-eval-after-load 'popwin
      ;; Use popwin for certain Magit buffers.
      (add-many-to-list
       'popwin:special-display-config
       '("*magit-edit-log*" :noselect t :height 0.2 :width 80)
       '("*magit-process*" :noselect t :height 0.2 :width 80)))

    (with-feature 'fullframe
      ;; Full frame Magit status.
      (fullframe magit-status magit-mode-quit-window nil))

    ;;; (Bindings) ;;;
    (define-key magit-status-mode-map (kbd "W")
      'user/magit-toggle-whitespace)

    (use-package magit-svn
      :if (executable-find "svn")
      :hook (magit-mode-hook . magit-svn-mode))
    (use-package magit-imerge
      :if (executable-find "git-imerge"))
    (use-package orgit
      :defer)
    (use-package magit-todos
      :disabled
      :hook (magit-mode-hook . magit-todos-mode))
    (use-package magit-org-todos
      :config
      (magit-org-todos-autoinsert))
    (use-package magit-find-file))

  (use-package git-timemachine
    :defer)

  (use-package git-gutter
    :defer
    :config
    (use-package git-gutter-fringe
      :if window-system
      :defer
      :config
      (validate-setq git-gutter-fr:side 'left-fringe)))

  (use-package git-messenger
    :defer
    :config
    (validate-setq git-messenger:show-detail t))

  (when (feature-p 'helm)
    (use-package helm-ls-git
      :defer
      ;; MELPA Stable only has 1.9.4, which doesn't load with helm 4.
      :pin "MELPA")
    (use-package helm-git-grep
      :defer
      :pin "MELPA"
      :commands helm-git-grep)
    (use-package helm-hunks
      :defer))

  (use-package magit-diff-flycheck
    :defer)

  (use-package magit-delta
    :if (executable-find "delta")))

(with-executable 'git
  (user--git-config))


(provide 'vcs/git)
;;; git.el ends here
