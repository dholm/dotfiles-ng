;;; completion.el --- Configures automatic code completion -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:


(defun user--company-mode-hook ()
  "Company mode hook."
  (user/complete-at-point-install)

  ;;; (Bindings) ;;;
  (when (current-local-map)
    (define-key (current-local-map) (user/get-key :code :auto-complete) 'company-complete)))


(defun user/auto-complete-p ()
  "True if auto-complete should be used.
auto-complete is no longer configured, so this is only true if it has
been enabled by hand; the mode files still use it to add their sources."
  (and (boundp 'global-auto-complete-mode)
       global-auto-complete-mode))


(defun user/company-mode-p ()
  "True if company should be used."
  (and (boundp 'global-company-mode)
       global-company-mode))


(defun user/complete-at-point-install ()
  "Install completion backend in complete-at-point."
  (setq
   ;; Insert completion backend into `completion-at-point'.
   completion-at-point-functions
   (cons 'user/complete-at-point
         (remove 'user/complete-at-point completion-at-point-functions))))


(defun user/company-check-expansion ()
  "Check if expression can be expanded by company."
  (save-excursion
    (if (looking-at "\\_>") t
      (backward-char 1)
      (if (looking-at "\\.") t
        (backward-char 1)
        (if (looking-at "->") t nil)))))


(defun user/complete-at-point ()
  "Complete thing at point using completion backend."
  (cond
   ((minibufferp) (minibuffer-complete))
   ((and (boundp 'company-mode) company-mode (user/company-check-expansion))
    #'company-complete-common)
   (t #'indent-for-tab-command)))


(defun add-ac-sources (&rest sources)
  "Add SOURCES for auto-complete after it has been loaded."
  (when (user/auto-complete-p)
    (dolist (source sources)
      (if (boundp 'ac-sources)
          (add-to-list 'ac-sources source)
        (error "Declaration of ac-sources is missing!")))))


(defun add-ac-modes (&rest major-modes)
  "Add MAJOR-MODES for auto-complete after it has been loaded."
  (when (user/auto-complete-p)
    (dolist (mode major-modes)
      (if (boundp 'ac-modes)
          (add-to-list 'ac-modes mode)
        (error "Declaration of ac-modes is missing!")))))


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
    :hook (company-mode-hook . user--company-mode-hook)
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
      :if window-system
      :after (company)
      :hook (company-mode-hook . company-quickhelp-mode)
      :config
      (validate-setq
       ;; Show quick help popup after half a second.
       company-quickhelp-delay 0.5))
    (use-package company-box
      :if (display-graphic-p)
      :hook (company-mode-hook . company-box-mode))

    (global-company-mode t)))

(user--completion-config)


(provide 'ux/completion)
;;; completion.el ends here
