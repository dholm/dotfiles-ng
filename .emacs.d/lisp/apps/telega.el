;;; telega.el --- Telegram client -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package telega
  :pin "MELPA"
  :commands (telega)
  :hook ((telega-load-hook . telega-mode-line-mode)
         (telega-load-hook . telega-notifications-mode)
         (telega-load-hook . global-telega-squash-message-mode))
  :config
  (when (feature-p 'alert)
    ;; telega-alert is shipped in telega's contrib directory, which is not
    ;; on the load path.
    (add-to-list 'load-path
                 (expand-file-name "contrib"
                                   (file-name-directory (locate-library "telega"))))
    (when (require 'telega-alert nil t)
      (telega-alert-mode 1))))


(provide 'apps/telega)
;;; telega.el ends here
