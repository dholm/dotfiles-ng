;;; plantuml.el --- Mode support for PlantUML. -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defconst *user-plantuml-jar-path*
  (path-join *user-cache-directory* "plantuml.jar")
  "Path to user's PlantUML jar file.")


(use-package plantuml-mode
  :defer
  :mode (("\\.puml$" . plantuml-mode))
  :bind-wrap
  (:map plantuml-mode-map
        ((:key :code :complete) . plantuml-complete-symbol)
        ((:key :code :compile) . plantuml-preview))
  :init
  (setq
   ;; Render diagrams locally instead of sending them to plantuml.com.
   ;; Prefer an installed plantuml command, otherwise use the jar, which
   ;; `plantuml-download-jar' installs on request.
   plantuml-default-exec-mode (if (executable-find "plantuml") 'executable 'jar))
  :config
  (validate-setq
   plantuml-jar-path *user-plantuml-jar-path*)

  (with-eval-after-load 'org-src
    (add-to-list
     ;; Enable PlantUML editing in org-mode code blocks.
     'org-src-lang-modes '("plantuml" . plantuml)))

  (use-package flycheck-plantuml
    ;; The checker runs the jar.
    :if (file-exists-p *user-plantuml-jar-path*)
    :config
    (flycheck-plantuml-setup)))


(provide 'modes/plantuml)
;;; plantuml.el ends here
