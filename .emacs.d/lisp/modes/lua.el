;;; lua.el --- Lua mode support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--lua-mode-hook ()
  "Lua mode hook."
  (user/gnu-global-enable))


(use-package lua-mode
  :if (executable-find "lua")
  :defer
  :init
  (add-hook 'lua-mode-hook 'user--lua-mode-hook))


(provide 'modes/lua)
;;; lua.el ends here
