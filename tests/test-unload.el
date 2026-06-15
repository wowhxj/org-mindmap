;;; test-unload.el --- Tests for org-mindmap load/unload lifecycle  -*- lexical-binding: t -*-

(require 'ert)
(require 'org-mindmap)

;;; Helpers

(defmacro org-mindmap-test--with-clean-slate (&rest body)
  "Run BODY ensuring `org-mindmap-mode' is off beforehand.
Restores `org-structure-template-alist', `minor-mode-map-alist',
`minor-mode-alist', and `minor-mode-list' afterward, so no test
leaves side-effects behind."
  (declare (indent 0))
  `(let ((saved-struct-alist org-structure-template-alist)
         (saved-mm-map-alist minor-mode-map-alist)
         (saved-mm-alist minor-mode-alist)
         (saved-mm-list minor-mode-list))
     (unwind-protect
         (progn
           (when (and (boundp 'org-mindmap-mode)
                      org-mindmap-mode)
             (org-mindmap-mode -1))
           ,@body)
       (setq org-structure-template-alist saved-struct-alist)
       (setq minor-mode-map-alist saved-mm-map-alist)
       (setq minor-mode-alist saved-mm-alist)
       (setq minor-mode-list saved-mm-list))))

(defmacro org-mindmap-test--with-clean-hooks (&rest body)
  "Run BODY with org hook variables restored afterward.
Prevents pollution of global hook values between tests."
  (declare (indent 0))
  `(let ((saved-metaup (default-value 'org-metaup-hook))
         (saved-metadown (default-value 'org-metadown-hook))
         (saved-metaleft (default-value 'org-metaleft-hook))
         (saved-metaright (default-value 'org-metaright-hook))
         (saved-tab (default-value 'org-tab-first-hook))
         (saved-metareturn (default-value 'org-metareturn-hook))
         (saved-ctrl-c (default-value 'org-ctrl-c-ctrl-c-hook)))
     (unwind-protect
         (progn ,@body)
       (set-default 'org-metaup-hook saved-metaup)
       (set-default 'org-metadown-hook saved-metadown)
       (set-default 'org-metaleft-hook saved-metaleft)
       (set-default 'org-metaright-hook saved-metaright)
       (set-default 'org-tab-first-hook saved-tab)
       (set-default 'org-metareturn-hook saved-metareturn)
       (set-default 'org-ctrl-c-ctrl-c-hook saved-ctrl-c))))

;;; Mode enable/disable

(ert-deftest org-mindmap-test-mode-enable-adds-hooks ()
  "Enabling the mode adds buffer-local org hooks."
  (org-mindmap-test--with-clean-hooks
   (with-temp-buffer
     (org-mode)
     (org-mindmap-mode 1)
     (should (memq #'org-mindmap--metaup org-metaup-hook))
     (should (memq #'org-mindmap--tab org-tab-first-hook))
     (should (memq #'org-mindmap--ctrl-c-ctrl-c org-ctrl-c-ctrl-c-hook)))))

(ert-deftest org-mindmap-test-mode-disable-removes-hooks ()
  "Disabling the mode removes buffer-local org hooks."
  (org-mindmap-test--with-clean-hooks
   (with-temp-buffer
     (org-mode)
     (org-mindmap-mode 1)
     (should (memq #'org-mindmap--metaup org-metaup-hook))
     (org-mindmap-mode -1)
     ;; After disable, the buffer-local value is killed (reduced to (t)),
     ;; reverting to the global default.  Verify the function is gone.
     (should-not (memq #'org-mindmap--metaup org-metaup-hook))
     (should-not (memq #'org-mindmap--tab org-tab-first-hook)))))

(ert-deftest org-mindmap-test-mode-registers-keymap ()
  "The minor mode's keymap is registered in `minor-mode-map-alist'."
  (with-temp-buffer
    (org-mode)
    (org-mindmap-mode 1)
    (should (assq 'org-mindmap-mode minor-mode-map-alist))
    (org-mindmap-mode -1)
    ;; The alist entry persists (that is `define-minor-mode' design);
    ;; the variable being nil marks the keymap inactive.
    (should (assq 'org-mindmap-mode minor-mode-map-alist))
    (should-not (bound-and-true-p org-mindmap-mode))))

(ert-deftest org-mindmap-test-mode-does-not-mutate-org-mode-map ()
  "RET in `org-mode-map' stays as `org-return' regardless of the mode."
  (with-temp-buffer
    (org-mode)
    (let ((before (keymap-lookup org-mode-map "RET")))
      (org-mindmap-mode 1)
      (should (eq (keymap-lookup org-mode-map "RET") before))
      (org-mindmap-mode -1)
      (should (eq (keymap-lookup org-mode-map "RET") before)))))

;;; Unload

(ert-deftest org-mindmap-test-unload ()
  "`unload-feature' cleans all global state and leaves no dangling entries."
  (org-mindmap-test--with-clean-slate
   (org-mindmap-test--with-clean-hooks
    ;; Enable the mode in a buffer so some state exists.
    (with-temp-buffer
      (org-mode)
      (org-mindmap-mode 1))

    ;; Pre-conditions: state exists.
    (should (assoc "m" org-structure-template-alist))
    (should (string= (cdr (assoc "m" org-structure-template-alist)) "mindmap"))
    (should (assq 'org-mindmap-mode minor-mode-map-alist))
    (should (assq 'org-mindmap-mode minor-mode-alist))
    (should (memq 'org-mindmap-mode minor-mode-list))
    (should (fboundp 'org-mindmap-return))
    (should (fboundp 'org-mindmap-mode))
    (let ((saved-ret (keymap-lookup org-mode-map "RET")))

      ;; The main event.
      (unload-feature 'org-mindmap t)

      ;; Functions are undefined.
      (should-not (fboundp 'org-mindmap-return))
      (should-not (fboundp 'org-mindmap--metaup))
      (should-not (fboundp 'org-mindmap-mode))

      ;; Minor-mode registries cleaned (by our unload function).
      (should-not (assq 'org-mindmap-mode minor-mode-map-alist))
      (should-not (assq 'org-mindmap-mode minor-mode-alist))
      (should-not (memq 'org-mindmap-mode minor-mode-list))

      ;; Structure template removed (by our unload function).
      (should-not (assoc "m" org-structure-template-alist))

      ;; org-mode-map is untouched.
      (should (eq (keymap-lookup org-mode-map "RET") saved-ret))

      ;; After unload, `current-active-maps' must not signal
      ;; void-variable from a dangling minor-mode-map-alist entry.
      (should (listp (current-active-maps)))

      ;; Hook values no longer reference unloaded functions.
      (should-not (memq #'org-mindmap--metaup
                        (default-value 'org-metaup-hook)))
      (should-not (memq #'org-mindmap--tab
                        (default-value 'org-tab-first-hook)))

      ;; The feature itself is gone.
      (should-not (featurep 'org-mindmap))

      ;; Re-require succeeds and the package works again.
      (require 'org-mindmap)
      (should (featurep 'org-mindmap))
      (should (fboundp 'org-mindmap-return))
      (with-temp-buffer
        (org-mode)
        (org-mindmap-mode 1)
        (should (assq 'org-mindmap-mode minor-mode-map-alist))
        (should (memq #'org-mindmap--metaup org-metaup-hook))
        (org-mindmap-mode -1))))))

;;; test-unload.el ends here
