(require 'ert)
(require 'org-mindmap)

(defmacro with-org-mindmap-regression (initial-content node-text action &rest body)
  "Set up a mindmap, move to NODE-TEXT, perform ACTION, then run BODY."
  (declare (indent 3))
  `(with-temp-buffer
     (org-mode)
     (setq indent-tabs-mode nil)
     (insert "#+begin_mindmap\n" ,initial-content "\n#+end_mindmap")
     (goto-char (point-min))
     (re-search-forward (regexp-quote ,node-text))
     (goto-char (match-beginning 0))
     (funcall ,action)
     ,@body))

(ert-deftest org-mindmap-regression-sibling-isolation-move ()
  "Verify that move commands do not swap nodes across the root boundary."
  (let ((initial "One ─┼ ⏴⏵ ── Identity"))
    (with-org-mindmap-regression initial "Identity"
                                 (lambda ()
                                   (should-error (org-mindmap-move-down)))
                                 (with-org-mindmap-regression initial "One"
                                                              (lambda ()
                                                                (should-error (org-mindmap-move-up)))))))

(ert-deftest org-mindmap-regression-demote-isolation ()
  "Verify that demotion selects a sibling from the same side."
  (let ((initial "One ─┬ ⏴⏵ ┬─ Identity\n     ╰      ╰─ Geography"))
    (with-org-mindmap-regression initial "Geography" #'org-mindmap-demote
                                 (let* ((region (org-mindmap-parser-get-region))
                                        (roots (org-mindmap-parser-parse-region (car region) (cdr region)))
                                        (root (car roots))
                                        (identity (cl-find "Identity" (org-mindmap-parser-node-children root) :key #'org-mindmap-parser-node-text :test #'string=)))
                                   (should (cl-some (lambda (c) (string= (org-mindmap-parser-node-text c) "Geography"))
                                                    (org-mindmap-parser-node-children identity)))))))

(ert-deftest org-mindmap-regression-find-node-at-point-width ()
  "Verify that find-node-at-point handles cursor on connector/whitespace."
  (let ((initial "⏴⏵ ── NodeA ── Child"))
    (with-temp-buffer
      (org-mode)
      (insert "#+begin_mindmap\n" initial "\n#+end_mindmap")
      (goto-char (point-min))
      (re-search-forward "NodeA")
      (backward-char 2)
      (let ((node (org-mindmap-find-node-at-point)))
        (should node)
        (should (string= (org-mindmap-parser-node-text node) "NodeA"))))))

(ert-deftest org-mindmap-regression-delete-focus-side ()
  "Verify that focus stays on the same side after deletion."
  (let ((initial "Left1 ─┬ ⏴⏵ ── Right1\nLeft2 ─╯"))
    (with-org-mindmap-regression initial "Left1" #'org-mindmap-delete-node
                                 (should (looking-at "Left2")))))
