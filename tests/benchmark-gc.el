;;; -*- lexical-binding: t -*-
;;; Benchmark: effect of gc-cons-percentage on org-mindmap performance
(require 'org-mindmap)

(defsubst benchmark-gc--conses ()
  "Return total conses from garbage-collect (alist format, Emacs 31+)."
  (nth 1 (assq 'conses (garbage-collect))))

(defun benchmark-map-12-gc-settings ()
  "Test the full parse→layout→draw pipeline with different gc-cons-percentage values."
  (with-temp-buffer
    (org-mode)
    (setq indent-tabs-mode nil)
    (insert-file-contents "big-map.org")
    (goto-char (point-min))
    (re-search-forward "^#\\+begin_mindmap")
    (let* ((region (org-mindmap-parser-get-region))
           (start (car region))
           (end (cdr region)))
      ;; Warm-up: run once to initialize caches, load libraries, etc.
      (let* ((props (org-mindmap-parse-properties start))
             (roots (org-mindmap-parser-parse-region start end)))
        (org-mindmap-build-tree-layout roots props)
        (with-temp-buffer
          (setq indent-tabs-mode nil)
          (let ((inhibit-read-only t))
            (dolist (root roots)
              (org-mindmap-draw-subtree root props)))))

      (message "\n=== GC Benchmark Results (20 iterations each, avg ms) ===")
      (message "%-30s %10s %10s %10s %10s %s" "Setting" "Parse" "Layout" "Draw" "Total" "Δ Conses/iter")

      (dolist (cfg '((0.1 . "0.1 (default)")
                     (0.5 . "0.5")
                     (0.7 . "0.7")
                     (0.9 . "0.9")
                     (0.95 . "0.95")))
        (let* ((gcp (car cfg))
               (label (cdr cfg))
               (t-parse 0.0)
               (t-layout 0.0)
               (t-draw 0.0)
               (gc-total 0))
          (dotimes (_ 20)
            (garbage-collect) ;; Clean slate
            (let* ((gc-before (benchmark-gc--conses))
                   (gc-cons-percentage gcp)
                   (st (float-time))
                   (props (org-mindmap-parse-properties start))
                   (roots (org-mindmap-parser-parse-region start end)))
              (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
              (let ((st (float-time)))
                (org-mindmap-build-tree-layout roots props)
                (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
              (let ((st (float-time)))
                (with-temp-buffer
                  (setq indent-tabs-mode nil)
                  (let ((inhibit-read-only t))
                    (dolist (root roots)
                      (org-mindmap-draw-subtree root props))))
                (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
              (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))

          (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                   label
                   (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                   (/ (+ t-parse t-layout t-draw) 20.0)
                   (/ gc-total 20.0))))

      ;; Also test the "standard" approach: gc-cons-threshold → most-positive-fixnum
      (let ((t-parse 0.0)
            (t-layout 0.0)
            (t-draw 0.0)
            (gc-total 0))
        (dotimes (_ 20)
          (garbage-collect)
          (let* ((gc-before (benchmark-gc--conses))
                 (gc-cons-threshold most-positive-fixnum)
                 (st (float-time))
                 (props (org-mindmap-parse-properties start))
                 (roots (org-mindmap-parser-parse-region start end)))
            (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
            (let ((st (float-time)))
              (org-mindmap-build-tree-layout roots props)
              (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
            (let ((st (float-time)))
              (with-temp-buffer
                (setq indent-tabs-mode nil)
                (let ((inhibit-read-only t))
                  (dolist (root roots)
                    (org-mindmap-draw-subtree root props))))
              (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
            (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))
        (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                 "threshold=most-positive-fixnum"
                 (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                 (/ (+ t-parse t-layout t-draw) 20.0)
                 (/ gc-total 20.0)))

      ;; Combined approach
      (let ((t-parse 0.0)
            (t-layout 0.0)
            (t-draw 0.0)
            (gc-total 0))
        (dotimes (_ 20)
          (garbage-collect)
          (let* ((gc-before (benchmark-gc--conses))
                 (gc-cons-percentage 0.9)
                 (gc-cons-threshold most-positive-fixnum)
                 (st (float-time))
                 (props (org-mindmap-parse-properties start))
                 (roots (org-mindmap-parser-parse-region start end)))
            (setq t-parse (+ t-parse (* 1000 (- (float-time) st))))
            (let ((st (float-time)))
              (org-mindmap-build-tree-layout roots props)
              (setq t-layout (+ t-layout (* 1000 (- (float-time) st)))))
            (let ((st (float-time)))
              (with-temp-buffer
                (setq indent-tabs-mode nil)
                (let ((inhibit-read-only t))
                  (dolist (root roots)
                    (org-mindmap-draw-subtree root props))))
              (setq t-draw (+ t-draw (* 1000 (- (float-time) st)))))
            (setq gc-total (+ gc-total (- (benchmark-gc--conses) gc-before)))))
        (message "%-30s %7.2f ms %7.2f ms %7.2f ms %7.2f ms %7.0f"
                 "gcp=0.9 + thresh=most-pos-fixnum"
                 (/ t-parse 20.0) (/ t-layout 20.0) (/ t-draw 20.0)
                 (/ (+ t-parse t-layout t-draw) 20.0)
                 (/ gc-total 20.0))))))

(benchmark-map-12-gc-settings)
