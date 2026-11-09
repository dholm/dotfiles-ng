;;; undo.el --- Configure Emacs undo -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-undo-tree-cache-directory*
  (path-join *user-cache-directory* "undo-tree")
  "Path to user's undo-tree cache store.")


;;; (Bindings) ;;;
(user/bind-key-global :basic :undo 'undo)
(user/bind-key-global :basic :redo 'undo-redo)

(use-package undo-tree
  ;; The global mode has to be enabled at startup.
  :demand
  ;; Only the visualizer is bound here. `undo-tree-map' remaps undo and redo
  ;; in buffers where the mode is on; binding them globally makes them fail
  ;; elsewhere and stops `global-undo-tree-mode' from turning itself on.
  :bind-wrap
  (((:key :util :undo-tree) . undo-tree-visualize))
  :config
  ;; Ensure that cache store exists.
  (make-directory *user-undo-tree-cache-directory* t)

  (validate-setq
   ;; Set up undo history cache store.
   undo-tree-history-directory-alist
   `((".*" . ,*user-undo-tree-cache-directory*))
   ;; Persistent undo history.
   undo-tree-auto-save-history t
   ;; Don't display in mode-line.
   undo-tree-mode-lighter ""
   ;; Display time stamps in visualizer by default.
   undo-tree-visualizer-timestamps t
   ;; Display diffs in visualizer by default.
   undo-tree-visualizer-diff t)

  ;; Compress undo history.
  (define-advice undo-tree-make-history-save-file-name
      (:filter-return (file-name) user-compress)
    "Save the undo history compressed."
    (concat file-name ".gz"))

  (global-undo-tree-mode t))


(provide 'ux/undo)
;;; undo.el ends here
