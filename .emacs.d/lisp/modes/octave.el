;;; octave.el --- Octave mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun user--octave-mode-hook ()
  "Initialize Octave mode."
  (eldoc-mode t))

(use-package octave
  :ensure nil
  :defer
  :hook (octave-mode-hook . user--octave-mode-hook))


(provide 'modes/octave)
;;; octave.el ends here
