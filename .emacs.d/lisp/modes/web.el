;;; web.el --- Web development -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--web-mode-hook ()
  "Web mode hook."
  (setq
   ;; Don't indent using tabs by default.
   indent-tabs-mode nil)

  (when (user/company-mode-p)
    (with-feature 'company-web
      (add-company-sources 'company-web-html)))

  (with-feature 'pandoc-mode
    (pandoc-mode t)))


(defmacro user--add-web-mode-hook (engine function)
  "In web mode hook, when using ENGINE, evaluate FUNCTION."
  `(add-hook 'web-mode-hook
             (lambda ()
               (when (string= web-mode-engine (symbol-name ,engine))
                 (funcall ,function)))))


(defun user/current-buffer-django-p ()
  "Evaluate to non-nil if the current buffer should use the `django` engine."
  (save-excursion
    (search-forward-regexp (concat "{% base\\|{% if\\|{% for\\|{% include\\|"
                                   "{% block\\|{% csrf_token %}") nil t)))


(use-package web-mode
  :defer
  :mode "\\.\\(html?\\|phtml\\|php[3-5]?\\)\\'"
  :hook ((web-mode-hook . user--web-mode-hook)
         (web-mode-hook . user/eglot-ensure)
         (html-mode-hook . user/eglot-ensure))
  :init
  (when (feature-p 'polymode)
    (add-auto-mode 'poly-javascript-erb-mode "\\.js\\.erb$")
    (add-auto-mode 'poly-coffee-erb-mode "\\.coffee\\.erb$")
    (add-auto-mode 'poly-html-erb-mode "\\.html\\.erb$"))
  (with-eval-after-load 'eglot
    ;; Use the HTML language server in web-mode.
    (add-to-list 'eglot-server-programs
                 `((web-mode :language-id "html")
                   . ,(eglot-alternatives
                       '(("vscode-html-language-server" "--stdio")
                         ("html-languageserver" "--stdio"))))))
  :config
  (validate-setq
   ;; Indent HTML automatically.
   web-mode-indent-style 2
   ;; Indentation offsets.
   web-mode-markup-indent-offset 2
   web-mode-css-indent-offset 2
   web-mode-code-indent-offset 2
   ;; Highlight current HTML element.
   web-mode-enable-current-element-highlight t)
  ;; Not validated: web-mode accepts predicate functions as well as regexps,
  ;; but its custom type only allows strings.
  (setq
   ;; Engine selection.
   web-mode-engines-alist
   '(("django" . user/current-buffer-django-p)
     ("php" . "\\.php[3-5]?")))

  (use-package restclient
    :defer)

  (use-package company-web
    :after (company))
  (use-package skewer-mode
    :defer)

  (with-executable 'prettier
    (use-package prettier
      :demand
      :config
      (global-prettier-mode t))))


(provide 'modes/web)
;;; web.el ends here
