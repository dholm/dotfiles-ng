;;; helm.el --- improved Emacs control -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user/helm-apropos ()
  "A context-aware helm apropos."
  (interactive)
  (let ((buffer-name "*helm-apropos*"))
    (cond
     ((derived-mode-p 'emacs-lisp-mode) (call-interactively #'helm-apropos))
     ((derived-mode-p 'sh-mode) (helm :sources '(helm-source-man-pages
                                                 helm-source-info-pages)
                                      :buffer buffer-name))
     ((derived-mode-p 'c-mode 'c++-mode) (helm :sources '(helm-source-man-pages)
                                               :buffer buffer-name))
     ((derived-mode-p 'python-mode) (helm-pydoc))
     (t (message (format "Apropos is unavailable for %S" major-mode))))))


(defun user/helm-navigate ()
  "A context-aware helm navigation aid."
  (interactive)
  (cond
     ((derived-mode-p 'prog-mode) (user/helm-navigate-prog))
     (t (user/helm-navigate-generic))))


(defun user/helm-navigate-prog ()
  "A context-aware helm for programming modes."
  (interactive)
  (let ((helm-sources '(helm-source-buffers-list))
        (current-file (or (buffer-file-name) default-directory)))
    (with-project project current-file
      ;; Bookmarks.
      (add-to-list 'helm-sources 'helm-source-bookmarks))

    (helm :sources helm-sources :buffer "*helm-navigate-prog*")))


(defun user/helm-navigate-generic ()
  "A somewhat context-aware generic helm."
  (interactive)
  (condition-case nil
      (let ((helm-sources '(helm-source-buffers-list
                            helm-source-recentf
                            helm-source-file-name-history
                            helm-source-file-cache
                            helm-source-buffer-not-found
                            helm-source-man-pages
                            helm-source-info-pages)))
        (cond
         ((eq system-type 'darwin)
          (progn
            (add-to-list 'helm-sources 'helm-source-mac-spotlight)))
         ((eq system-type 'gnu/linux)
          (progn
            (add-to-list 'helm-sources 'helm-source-tracker-search))))
        (helm :sources helm-sources :buffer "*helm-navigate-generic*"))
    ;; Fall back to helm-mini if an error occurs in one of the sources.
    (error (helm-mini))))


(defun user/helm-info-elisp ()
  "Search the Emacs Lisp manual with helm."
  (interactive)
  ;; The `helm-info-<manual>' commands are only defined once helm-info has
  ;; been loaded, and only for manuals that are installed.
  (require 'helm-info)
  (if (fboundp 'helm-info-elisp)
      (call-interactively #'helm-info-elisp)
    (user-error "The Emacs Lisp manual is not installed")))


(defun user/helm-mode ()
  "Start helm-mode."
  (helm-mode t)

  (with-feature 'helm-descbinds
    (helm-descbinds-mode t))

  ;; Filter out boring buffers.
  (dolist (pattern
           (list "\\*clang-complete" "\\*CEDET global" "\\*tramp/scpc"
                 "\\*epc con" "\\*Pymacs" "\\*Completions\\*"))
    (add-to-list 'helm-boring-buffer-regexp-list pattern))

  ;; Filter out boring files.
  (dolist (pattern
           (list "\\.elc$" "\\.pyc$" "^#.+#$" "^G[R]TAGS$" "^GPATH$" "^ID$"))
    (add-to-list 'helm-boring-file-regexp-list pattern)))

(use-package helm
  :diminish helm-mode
  ;; Since Helm depends on `eieio', enable it after package initialization.
  :hook (after-init-hook . user/helm-mode)
  :init
  (user/bind-key-global :nav :context 'user/helm-navigate)
  (user/bind-key-global :doc :apropos 'user/helm-apropos)
  (user/bind-key-global :emacs :elisp-search 'user/helm-info-elisp)
  :config
  (validate-setq
   ;; Idle delays.
   helm-input-idle-delay 0.0
   ;; Limit the number of candidates per source to a reasonable amount.
   helm-candidate-number-limit 75)

  (with-eval-after-load 'popwin
    (add-to-list
     'popwin:special-display-config
     '("helm" :regexp t :height 0.4 :position bottom)))

  ;;; (Packages) ;;;
  (use-package helm-descbinds
    :defer)
  (use-package helm-swoop
    :defer
    :init
    (user/bind-key-global :basic :swoop 'helm-swoop)
    (user/bind-key-global :basic :swoop-multi 'helm-multi-swoop)
    :config
    (validate-setq
     ;; Split window vertically when swooping.
     helm-swoop-split-direction 'split-window-horizontally)

    ;;; (Bindings) ;;;
    (define-key isearch-mode-map
      (user/get-key :basic :swoop) 'helm-swoop-from-isearch)
    (with-eval-after-load 'helm-swoop
      ;; From helm-swoop to helm-multi-swoop-all.
      (define-key helm-swoop-map
        (user/get-key :basic :swoop)
        'helm-multi-swoop-all-from-helm-swoop)))

  (use-package helm-adaptive
    :ensure helm
    :config
    (validate-setq
     ;; Put adaptive history in cache directory.
     helm-adaptive-history-file (path-join *user-cache-directory* "helm-adaptive-history")))

  (use-package helm-command
    :ensure helm
    :bind* ([remap execute-extended-command] . helm-M-x))

  (use-package helm-files
    :ensure helm
    :bind* (([remap find-file] . helm-find-files)
            :map helm-find-files-map
            ("C-k" . helm-ff-persistent-delete))
    :config
    ;; `helm-recentf-fuzzy-match' is set via Customize
    ;; Reason: https://emacs.stackexchange.com/a/106/5514
    (validate-setq
     ;; Don't prompt for new buffer.
     helm-ff-newfile-prompt-p nil
     helm-input-idle-delay 0.1
     ;; Don't show boring files.
     helm-ff-skip-boring-files t
     ;; Search for library in `require' and `declare-function' sexp.
     helm-ff-search-library-in-sexp t
     ;; Auto-complete in find-files.
     helm-ff-auto-update-initial-value t))

  (use-package helm-misc
    :ensure helm
    :bind* ([remap switch-to-buffer] . helm-mini))

  (use-package helm-buffers
    :ensure helm
    :bind (:map helm-buffer-map
                ("C-k" . helm-buffer-run-kill-persistent))
    :config
    (validate-setq
     ;; Use fuzzy matching for buffer names.
     helm-buffers-fuzzy-matching t
     ;; Don't check if remote files exist.
     helm-buffer-skip-remote-checking t))

  (use-package helm-ring
    :ensure helm
    :bind* (([remap yank-pop] . helm-show-kill-ring)
            ("C-c SPC" . helm-all-mark-rings)))

  (use-package helm-imenu
    :ensure helm
    :bind (("C-c n i" . helm-imenu-in-all-buffers)
           ("C-c n t" . helm-imenu))
    :config
    (validate-setq
     helm-imenu-fuzzy-match t)
    ;; Incompatible with validate-setq.
    (setq
     helm-imenu-execute-action-at-once-if-one nil))

  (use-package helm-bookmark
    :ensure helm
    :defer
    :bind ("C-x r l" . helm-filtered-bookmarks))

  (use-package helm-pages
    :ensure helm
    :defer
    :bind ("C-c n P" . helm-pages))

  (use-package helm-eval
    :ensure helm
    :defer
    :bind (("C-c h M-:" . helm-eval-expression-with-eldoc)
           ("C-c h *" . helm-calcul-expression)))

  (use-package helm-external
    :ensure helm
    :defer
    :bind ("C-c h x" . helm-run-external-command))

  (use-package helm-build-command
    :defer
    :vc (:url "https://github.com/tkf/helm-build-command")))


(provide 'utilities/helm)
;;; helm.el ends here
