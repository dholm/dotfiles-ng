;;; treesit.el --- Treesitter mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package treesit
  :ensure nil
  :if (and (version<= "29.1" emacs-version)
           (treesit-available-p))
  :config
  (validate-setq
   ;; Grammars that treesit-auto has no recipe for. The other languages
   ;; are left to treesit-auto, whose recipes pin revisions that work with
   ;; the tree-sitter ABI that Emacs is built with.
   treesit-language-source-alist
   '((elisp "https://github.com/Wilfred/tree-sitter-elisp")))

  (use-package treesit-auto
    :config
    (validate-setq
     ;; Ask before cloning and compiling missing grammars.
     treesit-auto-install 'prompt
     ;; treesit-auto has no tree-sitter-c revision for ABI 14, and the
     ;; current grammar does not load, so keep using `c-mode'.
     treesit-auto-langs (remq 'c treesit-auto-langs))

    (global-treesit-auto-mode)))


(provide 'modes/treesit)
;;; treesit.el ends here
