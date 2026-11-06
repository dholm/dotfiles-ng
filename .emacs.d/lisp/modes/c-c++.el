;;; c-c++.el --- initializes C/C++ modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--c-mode-common-hook ()
  "C-like languages mode hook."
  (setq
   ;; Indent using four spaces.
   c-basic-offset 4)

  ;; Override the indentation level of case labels in the K&R- and
  ;; Stroustrup styles so that they are indented one level beyond
  ;; the switch.
  (c-set-offset 'case-label '+)
  ;; Don't indent when inside `extern "<lang>"'.
  (c-set-offset 'inextern-lang 0)

  ;; Propertize "#if 0" regions as comments.
  (add-hook 'before-change-functions #'user--c-if0-invalidate nil t)
  (font-lock-add-keywords
   nil
   '((user/c-mode-font-lock-if0 (0 font-lock-comment-face prepend)))
   'add-to-end)

  ;; Enable Doxygen support.
  (doxygen-mode t)

  ;; Separate camel-case into separate words.
  (subword-mode t)

  (when (feature-p 'mic-paren)
    ;; Match context to open parentheses.
    (paren-toggle-open-paren-context t))

  ;; Load CEDET.
  (user--cedet-hook)

  (user/gnu-global-enable)
  (user/cscope-enable)

  (when (user/company-mode-p)
    (with-feature 'company-c-headers
      (add-company-sources 'company-c-headers)))

  ;; Enable LSP, if a language server is installed.
  (user/eglot-ensure)

  (user/smartparens-enable))


(defvar-local user--c-if0-regions 'unknown
  "Cached list of (START . END) regions inside #if 0, or `unknown'.")


(defun user--c-if0-invalidate (&rest _)
  "Forget the cached #if 0 regions after a change."
  (setq user--c-if0-regions 'unknown))


(defun user--c-if0-scan ()
  "Return the (START . END) regions of the buffer inside #if 0 blocks."
  (save-restriction
    (widen)
    (save-excursion
      (goto-char (point-min))
      (let ((depth 0) str start start-depth regions)
        (while (re-search-forward "^\\s-*#\\s-*\\(if\\|else\\|endif\\)" nil t)
          (setq str (match-string 1))
          (if (string= str "if")
              (progn
                (setq depth (1+ depth))
                (when (and (null start) (looking-at "\\s-+0"))
                  (setq start (match-end 0)
                        start-depth depth)))
            (when (and start (= depth start-depth))
              (push (cons start (match-beginning 0)) regions)
              (setq start nil))
            (when (string= str "endif")
              (setq depth (1- depth)))))
        (when (and start (> depth 0))
          (push (cons start (point-max)) regions))
        (nreverse regions)))))


(defun user/c-mode-font-lock-if0 (limit)
  "Propertize '#if 0' regions between point and LIMIT as comments.
The regions are found once after each buffer change, instead of
rescanning the buffer from the start for every chunk that font-lock
fontifies."
  (when (eq user--c-if0-regions 'unknown)
    (setq user--c-if0-regions (user--c-if0-scan)))
  (let ((from (point)))
    (dolist (region user--c-if0-regions)
      (when (and (< (car region) limit) (> (cdr region) from))
        (c-put-font-lock-face (max (car region) from) (min (cdr region) limit)
                              'font-lock-comment-face))))
  nil)


(defun user/c++-header-file-p ()
  "Return non-nil if in a C++ header."
  (and (string-match "\\.h$"
                   (or (buffer-file-name)
                      (buffer-name)))
     (save-excursion
       (re-search-forward "\\_<class\\_>" nil t))))


(use-package cc-mode
  :defer
  :hook (c-mode-common-hook . user--c-mode-common-hook)
  :init
  ;; Detect if inside a C++ header file.
  (add-magic-mode 'c++-mode 'user/c++-header-file-p)
  :config
  (add-many-to-list
   'c-default-style
   ;; Default mode for C.
   '(c-mode . "K&R")
   ;; Default mode for C++.
   '(c++-mode . "Stroustrup"))

  ;;; (Packages) ;;;
  (use-package cc-vars
    :ensure cc-mode
    :config
    (validate-setq
     ;; Support completion using tab.
     c-tab-always-indent nil
     c-insert-tab-function 'indent-for-tab-command))

  (use-package company-c-headers
    :after (company))
  (use-package flycheck-pkg-config
    :if (executable-find "pkg-config"))
  (use-package clang-format
    :if (executable-find "clang")
    :bind-wrap
    (:map c-mode-base-map
          ((:key :code :tidy) . clang-format-region)))
  (use-package helm-ctest
    :if (executable-find "ctest")
    :bind-wrap
    (:map c-mode-base-map
          ((:key :code :test) . helm-ctest)))
  (use-package flycheck-clang-analyzer
    :after flycheck
    :if (executable-find "scan-build")
    :config (flycheck-clang-analyzer-setup))
  (use-package flycheck-clang-tidy
    :if (executable-find "clang-tidy")
    :config
    (flycheck-clang-tidy-setup))
  (use-package flycheck-clangcheck
    :if (executable-find "clang-check"))
  (use-package flycheck-flawfinder
    :if (executable-find "flawfinder")
    :config
    (flycheck-flawfinder-setup))
  (use-package google-c-style))


(provide 'modes/c-c++)
;;; c-c++.el ends here
