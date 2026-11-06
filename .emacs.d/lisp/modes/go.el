;;; go.el --- Go mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--go-mode-hook ()
  "Go mode hook."
  ;; Format Go code before saving it.
  (add-hook 'before-save-hook #'gofmt-before-save nil t)

  ;; Don't automatically break lines, gofmt will handle formatting.
  (auto-fill-mode -1)

  ;; Camel-case separates words.
  (subword-mode t)

  (user/tags-try-enable)

  ;; Disable whitespace mode settings that don't make sense in Go.
  (user/whitespace-disable-style '(lines lines-tail))

  (when (feature-p 'gotest)
    ;; Prepend compilation error regexes from gotest for current
    ;; buffer.
    (dolist (elt (reverse go-test-compilation-error-regexp-alist))
      (add-to-list 'compilation-error-regexp-alist elt t))))

(use-package go-mode
  :if (executable-find "go")
  :defer
  :bind-wrap
  (:map go-mode-map
        ((:key :doc :describe) . godef-describe)
        ((:key :doc :reference) . godoc)
        ((:key :nav :switch-spec-impl) . go-goto-imports))
  :hook (go-mode-hook . user--go-mode-hook)
  :config
  (validate-setq
   ;; Hide errors as they are managed by Flycheck.
   gofmt-show-errors nil)

  (with-executable 'goimports
    (validate-setq
     ;; Use goimports as formatter so that imports are updated at the
     ;; same time.
     gofmt-command "goimports"))

  (use-package gotest
    ;; The compilation error regexps should be set up with go-mode.
    :demand
    :bind-wrap
    (:map go-mode-map
          ((:key :code :test) . go-test-current-project)
          ((:key :code :run) . go-run))
    :config
    ;; Copy compilation error regexes from gotest.
    (dolist (elt go-test-compilation-error-regexp-alist-alist)
      (add-to-list 'compilation-error-regexp-alist-alist elt)))
  (use-package go-tag
    :if (executable-find "gomodifytags"))

  (use-package flycheck-golangci-lint
    :hook (go-mode-hook . flycheck-golangci-lint-setup)
    :config
    (validate-setq
     ;; Default to using fast linters only.
     flycheck-golangci-lint-fast t))

  (use-package go-fill-struct
    :if (executable-find "fillstruct"))

  (use-package go-gen-test
    :if (executable-find "gotests")
    :bind-wrap (:map go-mode-map
                     ((:key :code :generate-test)
                      . go-gen-test-dwim)))

  (use-package go-template-mode
    :mode ("\\.\\(gotmpl\\|tpl\\|tmpl\\)\\'" . go-template-mode)))


(provide 'modes/go)
;;; go.el ends here
