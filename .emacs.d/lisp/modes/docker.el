;;; docker.el --- Configure Emacs Docker mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package dockerfile-mode
  :hook ((dockerfile-mode-hook dockerfile-ts-mode-hook) . user/eglot-ensure))

(use-package docker-compose-mode
  :defer t)


(provide 'modes/docker)
;;; docker.el ends here
