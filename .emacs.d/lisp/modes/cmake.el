;;; cmake.el --- Initializes CMake mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--cmake-mode-hook ()
  "Initialize makefile mode."
  (unless (derived-mode-p 'prog-mode)
    (user--prog-mode-hook))

  (validate-setq
   ;; Indent using spaces.
   indent-tabs-mode nil)

  ;; Separate camel-case into separate words.
  (subword-mode t))

(use-package cmake-mode
  :if (executable-find "cmake")
  :defer
  :hook ((cmake-mode-hook cmake-ts-mode-hook) . user--cmake-mode-hook)
  :config
  (use-package cmake-font-lock
    :hook (cmake-mode-hook . cmake-font-lock-activate)))

;; Not nested in cmake-mode's :config, which doesn't run when files open in
;; cmake-ts-mode.
(use-package eldoc-cmake
  :if (executable-find "cmake")
  :hook ((cmake-mode-hook cmake-ts-mode-hook) . eldoc-cmake-enable))


(provide 'modes/cmake)
;;; cmake.el ends here
