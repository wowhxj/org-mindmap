;; -*- lexical-binding: t -*-
(require 'org-mindmap)

(defun benchmark-map-12-profiled ()
  (with-temp-buffer
    (org-mode)
    (setq indent-tabs-mode nil)
    (insert-file-contents "big-map.org")
    (goto-char (point-min))
    (re-search-forward "^#\\+begin_mindmap")
    (let* ((region (org-mindmap-parser-get-region))
           (start (car region))
           (end (cdr region))
           (roots nil)
           (props (org-mindmap-parse-properties start)))

      (profiler-start 'cpu)
      (dotimes (_ 20)
        (setq roots (org-mindmap-parser-parse-region start end))
        (org-mindmap-build-tree-layout roots props)
        (with-temp-buffer
          (setq indent-tabs-mode nil)
          (let ((inhibit-read-only t))
            (dolist (root roots)
              (org-mindmap-draw-subtree root props)))))
      (profiler-stop)
      (profiler-report))))

(benchmark-map-12-profiled)
