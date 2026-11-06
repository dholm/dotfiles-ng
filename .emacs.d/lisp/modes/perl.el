;;; perl.el --- initializes Perl modes -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--perl-mode-hook ()
  "Perl mode hook."
  (user/gnu-global-enable)

  (when (user/auto-complete-p)
    (with-feature 'perl-completion
      (add-ac-sources 'ac-source-perl-completion))))


(use-package perl-mode
  :defer
  :init
  (add-hook 'perl-mode-hook 'user--perl-mode-hook))


(provide 'modes/perl)
;;; perl.el ends here
