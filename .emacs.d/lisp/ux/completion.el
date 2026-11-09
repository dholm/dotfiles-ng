;;; completion.el --- Configures automatic code completion -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:


(defun user/company-mode-p ()
  "True if company should be used."
  (and (boundp 'global-company-mode)
       global-company-mode))


(defun user--company-graphic-popups ()
  "Use the popups that need a graphical frame, if this buffer is in one.
Checked per buffer, since the daemon serves both kinds of frames."
  (when (and company-mode (display-graphic-p))
    (company-box-mode t)
    (company-quickhelp-local-mode t)))


(defun company-complete-common-or-selection ()
  "Insert the common part of all candidates, or the selection."
  (interactive)
  (when (company-manual-begin)
    (let ((tick (buffer-chars-modified-tick)))
      (call-interactively 'company-complete-common)
      (when (eq tick (buffer-chars-modified-tick))
        (let ((company-selection-wrap-around t))
          (call-interactively 'company-complete-selection))))))



(defun add-company-sources (&rest sources)
  "Add SOURCES for company completion in current mode, if it has been loaded."
  (when (user/company-mode-p)
    (when (boundp 'company-backends)
      (setq-local
       company-backends
       (append sources company-backends)))))


(defun user--completion-config ()
  "Initialize automatic code completion."
  (setq
   ;; Activate completion on tab.
   tab-always-indent 'complete
   ;; Cycle completions in minibuffer below a certain threshold.
   completion-cycle-threshold 5)

  ;; Allow completion of acronyms and initialisms.
  (add-to-list 'completion-styles 'initials t)

  ;;; (Packages) ;;;
  (use-package company
    :diminish company-mode
    ;; Load company and enable it everywhere once init is done. The global
    ;; mode can't be enabled from :config, which only runs once something
    ;; loads company.
    :hook (after-init-hook . global-company-mode)
    :config
    (validate-setq
     ;; Do not trigger completion automatically.
     company-idle-delay nil
     ;; Complete immediately.
     company-minimum-prefix-length 0
     ;; Show commonly used matches first.
     company-transformers '(company-sort-by-occurrence)
     ;; Align annotations to the right of tooltip.
     company-tooltip-align-annotations t
     ;; Active company frontends.
     company-frontends
     '(company-pseudo-tooltip-unless-just-one-frontend
       company-preview-frontend
       company-echo-metadata-frontend))

    (define-key company-active-map
      (user/get-key :code :complete) 'company-complete-selection)
    (define-key company-active-map
      (user/get-key :code :try-complete) 'company-complete-common-or-selection)
    (define-key company-active-map
      (user/get-key :basic :forward-line) 'company-select-next)
    (define-key company-active-map
      (user/get-key :basic :backward-line) 'company-select-previous)
    (define-key company-mode-map
      (user/get-key :code :auto-complete) 'company-complete)

    (use-package company-dabbrev-code
      :ensure company
      :config
      (validate-setq
       ;; Complete even outside of code.
       company-dabbrev-code-everywhere t))
    (use-package company-flx
      :after (company)
      :config
      (company-flx-mode t))
    (use-package company-quickhelp
      :defer t
      :config
      (validate-setq
       ;; Show quick help popup after half a second.
       company-quickhelp-delay 0.5))
    (use-package company-box
      :defer t)
    (add-hook 'company-mode-hook #'user--company-graphic-popups)))

(user--completion-config)


(provide 'ux/completion)
;;; completion.el ends here
