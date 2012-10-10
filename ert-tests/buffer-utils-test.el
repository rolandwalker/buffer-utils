
;;; requires and setup

(require 'buffer-utils)


;;; buffer-utils-huge-p

(ert-deftest buffer-utils-huge-p-01 nil
  "Not a huge buffer"
  (should-not
   (with-temp-buffer
     (dolist (i (number-sequence 1 10000))
       (insert (format "%d\n" i)))
     (buffer-utils-huge-p))))

(ert-deftest buffer-utils-huge-p-02 nil
  "Is a huge buffer"
  (should
   (with-temp-buffer
     (dolist (i (number-sequence 1 100000))
       (insert (format "%d\n" i)))
     (buffer-utils-huge-p))))

(ert-deftest buffer-utils-huge-p-03 nil
  "Bind buffer-utils-huge-cutoff"
  (should
   (with-temp-buffer
     (dolist (i (number-sequence 1 10000))
       (insert (format "%d\n" i)))
     (let ((buffer-utils-huge-cutoff 1000))
       (buffer-utils-huge-p)))))

(ert-deftest buffer-utils-huge-p-04 nil
  "Bind buffer-utils-huge-cutoff on empty buffer"
  (should-not
   (with-temp-buffer
     (let ((buffer-utils-huge-cutoff 1000))
       (buffer-utils-huge-p)))))


;;; buffer-utils-narrowed-p

(ert-deftest buffer-utils-narrowed-p-01 nil
  "Not narrowed"
  (should-not
   (with-temp-buffer
     (dolist (i (number-sequence 1 100))
       (insert (format "%d\n" i)))
     (buffer-utils-narrowed-p))))

(ert-deftest buffer-utils-narrowed-p-02 nil
  "Is narrowed"
  (should
   (with-temp-buffer
     (dolist (i (number-sequence 1 10000))
       (insert (format "%d\n" i)))
     (narrow-to-region 3 30)
     (buffer-utils-narrowed-p))))

(ert-deftest buffer-utils-narrowed-p-03 nil
  "Narrow to full size is not narrowed"
  (should-not
   (with-temp-buffer
     (dolist (i (number-sequence 1 10000))
       (insert (format "%d\n" i)))
     (narrow-to-region (point-min) (point-max))
     (buffer-utils-narrowed-p))))


;;; buffer-utils-most-recent-file-associated

(ert-deftest buffer-utils-most-recent-file-associated-01 nil
  "m-r-file-associated in a recent file buffer"
  (let ((tmpfile (make-temp-file "buffer-utils-test-file-"))
        (orig-buf (current-buffer)))
    (unwind-protect
        (progn
          (with-temp-file tmpfile
            (dolist (i (number-sequence 1 100))
              (insert (format "%d\n" i))))
          (find-file tmpfile)
          (should (eq (current-buffer)
                      (buffer-utils-most-recent-file-associated)))
          (should-not (eq (current-buffer)
                          (buffer-utils-most-recent-file-associated 'skip-current))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (when (get-file-buffer tmpfile)
          (kill-buffer (get-file-buffer tmpfile)))
        (delete-file tmpfile)))))

(ert-deftest buffer-utils-most-recent-file-associated-02 nil
  "m-r-file-associated in a non-file buffer"
  (let ((tmpfile (make-temp-file "buffer-utils-test-file-"))
        (orig-buf (current-buffer)))
    (unwind-protect
        (progn
          (with-temp-file tmpfile
            (dolist (i (number-sequence 1 100))
              (insert (format "%d\n" i))))
          (find-file tmpfile)
          (switch-to-buffer "*scratch*")
          (should-not (eq (current-buffer)
                          (buffer-utils-most-recent-file-associated)))
          (should-not (eq (current-buffer)
                          (buffer-utils-most-recent-file-associated 'skip-current)))
          (should (eq (get-file-buffer tmpfile)
                      (buffer-utils-most-recent-file-associated)))
          (should (eq (get-file-buffer tmpfile)
                      (buffer-utils-most-recent-file-associated 'skip-current))))
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (when (get-file-buffer tmpfile)
          (kill-buffer (get-file-buffer tmpfile)))
        (delete-file tmpfile)))))

(ert-deftest buffer-utils-most-recent-file-associated-03 nil
  "m-r-file-associated in a second file-associated buffer"
  (let ((tmpfile (make-temp-file "buffer-utils-test-file-"))
        (tmpfile2 (make-temp-file "buffer-utils-test-file-"))
        (orig-buf (current-buffer)))
    (unwind-protect
        (progn
          (with-temp-file tmpfile
            (dolist (i (number-sequence 1 100))
              (insert (format "%d\n" i))))
          (with-temp-file tmpfile2
            (dolist (i (number-sequence 1 100))
              (insert (format "%d\n" i))))
          (find-file tmpfile)
          (find-file tmpfile2)
          (should (eq (get-file-buffer tmpfile2)
                      (buffer-utils-most-recent-file-associated)))
          (should (eq (get-file-buffer tmpfile)
                      (buffer-utils-most-recent-file-associated 'skip-current))))
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (when (get-file-buffer tmpfile)
          (kill-buffer (get-file-buffer tmpfile)))
        (when (get-file-buffer tmpfile2)
          (kill-buffer (get-file-buffer tmpfile2)))
        (delete-file tmpfile)
        (delete-file tmpfile2)))))


;;; buffer-utils-in-mode

(ert-deftest buffer-utils-in-mode-01 nil
  "in mode"
  (should
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode nil 'grep-mode))))

(ert-deftest buffer-utils-in-mode-02 nil
  "with explicit buffer"
  (should
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode (current-buffer) 'grep-mode))))

(ert-deftest buffer-utils-in-mode-03 nil
  "mismatched mode"
  (should-not
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode (current-buffer) 'compilation-mode))))

(ert-deftest buffer-utils-in-mode-04 nil
  "derived mode"
  (should
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode (current-buffer) 'compilation-mode 'derived))))

(ert-deftest buffer-utils-in-mode-05 nil
  "mismatched derived mode"
  (should-not
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode (current-buffer) 'emacs-lisp-mode 'derived))))

(ert-deftest buffer-utils-in-mode-06 nil
  "derived on identical mode"
  (should
   (with-temp-buffer
     (grep-mode)
     (buffer-utils-in-mode (current-buffer) 'grep-mode 'derived))))


;;; buffer-utils-first-matching

(ert-deftest buffer-utils-first-matching-01 nil
  "find first file-associated"
  (let ((buf nil)
        (tmpfile (make-temp-file "buffer-utils-test-file-"))
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= i 5)
        (switch-to-buffer buf
          (write-file tmpfile))))
    (switch-to-buffer orig-buf)
    (unwind-protect
        (progn
          (should (eq
                   (get-file-buffer tmpfile)
                   (buffer-utils-first-matching 'buffer-file-name))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (when (get-file-buffer tmpfile)
          (kill-buffer (get-file-buffer tmpfile)))
        (delete-file tmpfile)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-first-matching-02 nil
  "find first with local variable"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (set (make-local-variable 'buffer-utils-test-variable) 1))))
    (unwind-protect
        (progn
          (should (memq
                   (buffer-utils-first-matching #'(lambda (buf)
                                                    (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf))))
                   group)))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-first-matching-03 nil
  "with skip-current"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 5 i)
        (with-current-buffer buf
          (push buf group)
          (set (make-local-variable 'buffer-utils-test-variable) 1))))
    (unwind-protect
        (progn
          (switch-to-buffer "*buffer-utils-test-buffer-5*")
          (should-not (memq
                       (buffer-utils-first-matching #'(lambda (buf)
                                                        (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf))) 'skip-current)
                       group)))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))


;;; buffer-utils-all-matching

(ert-deftest buffer-utils-all-matching-01 nil
  "file-associated"
  (let ((buf nil)
        (tmpfile (make-temp-file "buffer-utils-test-file-"))
        (orig-buf (current-buffer))
        (group (buffer-utils-all-matching 'buffer-file-name)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= i 5)
        (with-current-buffer buf
          (write-file tmpfile)
          (push (get-file-buffer tmpfile) group))))
    (unwind-protect
        (progn
          (should-not
           (set-exclusive-or group
            (buffer-utils-all-matching 'buffer-file-name))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (when (get-file-buffer tmpfile)
          (kill-buffer (get-file-buffer tmpfile)))
        (delete-file tmpfile)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-all-matching-02 nil
  "buffer-local variable"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer))
        (group (buffer-utils-all-matching #'(lambda (buf)
                                              (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf))))))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (set (make-local-variable 'buffer-utils-test-variable) 1))))
    (unwind-protect
        (progn
          (should-not
           (set-exclusive-or group
            (buffer-utils-all-matching #'(lambda (buf)
                                           (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf)))))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-all-matching-03 nil
  "with skip-current"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer))
        (group (buffer-utils-all-matching #'(lambda (buf)
                                              (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf))))))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (set (make-local-variable 'buffer-utils-test-variable) 1))))
    (unwind-protect
        (progn
          (switch-to-buffer "*buffer-utils-test-buffer-5*")
          (should (equal
                   (list (current-buffer))
                   (set-exclusive-or group
                                     (buffer-utils-all-matching #'(lambda (buf)
                                                                    (ignore-errors (buffer-local-value 'buffer-utils-test-variable buf))) 'skip-current)))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))


;;; buffer-utils-all-in-mode

(ert-deftest buffer-utils-all-in-mode-01 nil
  "in mode"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer))
        (group (buffer-utils-all-in-mode 'grep-mode)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (grep-mode))))
    (unwind-protect
        (progn
          (should-not
           (set-exclusive-or group
            (buffer-utils-all-in-mode 'grep-mode))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-all-in-mode-02 nil
  "derived matches same mode"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer))
        (group (buffer-utils-all-in-mode 'grep-mode)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (grep-mode))))
    (unwind-protect
        (progn
          (should-not
           (set-exclusive-or group
            (buffer-utils-all-in-mode 'grep-mode 'derived))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-all-in-mode-03 nil
  "derived"
  (let ((buf nil)
        (group nil)
        (orig-buf (current-buffer))
        (group (buffer-utils-all-in-mode 'grep-mode)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
      (when (= 1 (% i 2))
        (with-current-buffer buf
          (push buf group)
          (grep-mode))))
    (unwind-protect
        (progn
          (should-not
           (set-exclusive-or group
            (buffer-utils-all-in-mode 'compilation-mode 'derived))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))


;;; buffer-utils-save-order

(ert-deftest buffer-utils-save-order-01 nil
  "order changed / restored"
  (let ((buf nil)
        (order nil)
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i))))
    (unwind-protect
        (progn
          (setq order (buffer-list))
          (buffer-utils-save-order
            (switch-to-buffer "*buffer-utils-test-buffer-5*")
            (bury-buffer (current-buffer))
            (switch-to-buffer "*buffer-utils-test-buffer-6*")
            (should-not (equal order (buffer-list))))
          (should (equal order (buffer-list))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

;;; buffer-utils-set-order

(ert-deftest buffer-utils-set-order-01 nil
  "Set full order"
  (let ((buf nil)
        (existing-bufs (buffer-list))
        (new-order nil)
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i))))
    (unwind-protect
        (progn
          (setq new-order existing-bufs)
          (dotimes (i 10)
            (if (= 1 (% i 2))
                (push (get-buffer (format "*buffer-utils-test-buffer-%s*" i)) new-order)
                ;; else
              (add-to-list 'new-order (get-buffer (format "*buffer-utils-test-buffer-%s*" i)) 'append)))
          (should-not (equal new-order (buffer-list)))
          (buffer-utils-set-order new-order)
          (should (equal new-order (buffer-list))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))

(ert-deftest buffer-utils-set-order-02 nil
  "Set partial order"
  (let ((buf nil)
        (existing-bufs (buffer-list))
        (new-order nil)
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i))))
    (unwind-protect
        (progn
          (dotimes (i 10)
            (when (= 1 (% i 2))
              (push (get-buffer (format "*buffer-utils-test-buffer-%s*" i)) new-order)))
          (should-not (equal new-order (subseq (buffer-list) 0 5)))
          (buffer-utils-set-order new-order)
          (should (equal new-order (subseq (buffer-list) 0 5))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))


;;; buffer-utils-bury-and-forget

(ert-deftest buffer-utils-bury-and-forget-01 nil
  "bury"
  (let ((buf nil)
        (testbuf "*buffer-utils-test-buffer-5*")
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (setq buf (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i))))
    (unwind-protect
        (progn
          (callf get-buffer testbuf)
          (should testbuf)
          (should-not (eq testbuf (car (last (buffer-list)))))
          (switch-to-buffer testbuf)
          (buffer-utils-bury-and-forget testbuf)
          (should (eq testbuf (car (last (buffer-list)))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf))))))))

(ert-deftest buffer-utils-bury-and-forget-02 nil
  "forget"
  :tags '(:interactive)
  :expected-result (if (fboundp 'unrecord-window-buffer) :passed :failed)
  (let ((win nil)
        (testbuf "*buffer-utils-test-buffer-5*")
        (testbuf2 "*buffer-utils-test-buffer-6*")
        (orig-buf (current-buffer)))
    (dotimes (i 10)
      (get-buffer-create (format "*buffer-utils-test-buffer-%s*" i)))
    (unwind-protect
        (progn
          (callf get-buffer testbuf)
          (callf get-buffer testbuf2)
          (should testbuf)
          (switch-to-buffer testbuf)
          (setq win (selected-window))
          (should-not (memq testbuf (mapcar 'car (window-prev-buffers win))))
          (switch-to-buffer testbuf2)
          (should     (memq testbuf (mapcar 'car (window-prev-buffers win))))
          (buffer-utils-bury-and-forget testbuf)
          (should-not (memq testbuf (mapcar 'car (window-prev-buffers win)))))
      ;; unwind
      (with-demoted-errors
        (switch-to-buffer orig-buf)
        (dotimes (i 10)
          (setq buf (get-buffer (format "*buffer-utils-test-buffer-%s*" i)))
          (when buf
            (kill-buffer buf)))))))


;;
;; Emacs
;;
;; Local Variables:
;; indent-tabs-mode: nil
;; mangle-whitespace: t
;; require-final-newline: t
;; coding: utf-8
;; byte-compile-warnings: (not cl-functions)
;; End:
;;

;;; buffer-utils-test.el ends here
