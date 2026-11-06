;;; xml.el --- initializes XML modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--xml-mode-common-hook ()
  "XML common mode hook."
  ;; Outline XML support.
  (setq-local
   outline-regexp "^[ \t]*<[a-zA-Z]+")

  ;;; (Bindings) ;;;
  (user/bind-key-local :code :tidy 'user/xml-tidy-buffer-or-region))


(defun user--nxml-mode-hook ()
  "XML mode hook."
  (user--xml-mode-common-hook)

  (with-feature 'sgml-mode
    (hs-minor-mode t))

  (with-feature 'tidy
    (tidy-build-menu nxml-mode-map))

  ;;; (Bindings) ;;;
  (local-set-key (kbd "<return>") 'newline-and-indent))


(defun user--dtd-mode-hook ()
  "DTD mode hook."
  (user--xml-mode-common-hook)

  (with-feature 'tidy
    (tidy-build-menu dtd-mode-map)))


(defun user/xml-tidy-buffer-or-region ()
  "Pretty print XML in current buffer or region."
  (interactive)
  (let ((begin (if (use-region-p) (region-beginning) (point-min)))
        (end (if (use-region-p) (region-end) (point-max))))
    (user/xml-tidy-region begin end)))


(defun user/xml-tidy-region (begin end)
  "Pretty print XML between BEGIN and END."
  (interactive "r")
  (save-excursion
    (let ((end-marker (copy-marker end)))
      (goto-char begin)
      ;; Put each tag that directly follows another on its own line.
      (while (re-search-forward ">\\([ \t]*\\)<" end-marker t)
        (replace-match "\n" t t nil 1)
        (backward-char))
      (indent-region begin end-marker)
      (set-marker end-marker nil))))


(use-package nxml-mode
  :ensure nil
  :defer
  ;; SVG files are left to image-mode, where C-c C-c shows the XML.
  :mode ("\\.\\(xml\\|xsd\\|xslts\\|rss\\|plist\\|rng\\|rnc\\)\\'" . nxml-mode)
  :magic ("<\\?xml" . nxml-mode)
  :init
  ;; Use nxml-mode for XML
  (fset 'xml-mode 'nxml-mode)

  (add-hook 'nxml-mode-hook 'user--nxml-mode-hook)
  :config
  ;; Enable hide/show support for XML.
  (add-to-list
   'hs-special-modes-alist
   '(nxml-mode
     "<!--\\|<[^/>]>\\|<[^/][^>]*[^/]>"
     ""
     ;; Comment start.
     "<!--"
     sgml-skip-tag-forward nil)))

(use-package tdtd
  :defer
  :vc (:url "https://github.com/tkg/tdtd")
  :mode (("\\.dtd$" . dtd-mode))
  :init
  (add-hook 'dtd-mode-hook 'user--dtd-mode-hook))


(provide 'modes/xml)
;;; xml.el ends here
