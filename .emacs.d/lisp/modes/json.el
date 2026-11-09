;;; json.el --- JSON mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package json-mode
  ;; GNU ELPA has an unrelated package with the same name.
  :pin "MELPA Stable"
  :defer
  :mode "\\.bowerrc$"
  :config
  (use-package json-navigator)
  (use-package jq-format
    :if (executable-find "jq")))

(use-package jsonnet-mode
  :pin "MELPA"
  :defer t)


(provide 'modes/json)
;;; json.el ends here
