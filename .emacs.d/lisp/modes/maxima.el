;;; maxima.el --- Maxima integration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package maxima
  :if (executable-find "maxima")
  :defer t
  :mode ("\\.mac\\'" . maxima-mode)
  :interpreter ("maxima" . maxima-mode)
  :config
  (validate-setq
   maxima-display-maxima-buffer nil)
  (with-eval-after-load 'org
    ;; Render LaTeX fragments at twice the size.
    (setq org-format-latex-options
          (plist-put org-format-latex-options :scale 2.0)))

  (use-package company-maxima
    :config
    (add-to-list 'company-backends '(company-maxima-symbols company-maxima-libraries))))


(provide 'modes/maxima)
;;; maxima.el ends here
