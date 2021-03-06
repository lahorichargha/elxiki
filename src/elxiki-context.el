;;; elxiki-context.el --- How to interpret a given elxiki line.

;;; Commentary:
;; This is where elxiki interprets information about the elxiki
;; lines. To extend, take a look at `elxiki-context-functions' and
;; `elxiki-context-post-functions'.

;;; Code:
(defun elxiki-context-from-ancestry (ancestry)
  "Takes a list of line infos and returns them as a context alist.
ANCESTRY should be of the form returned by `elxiki-line-get-ancestry'."
  (let (directory menu prefix name last-type)
    (while ancestry
      (setq prefix (caar ancestry))
      (setq name (cadar ancestry))
      (cond
       ;; Absolute, so reset directory.
       ((member (string-to-char name) '(?/ ?~))
        (setq directory (expand-file-name name))
        (setq last-type 'directory))
       ;; If this is the first item and it starts with '.', treat it
       ;; as a directory.
       ((and (null last-type)
             (= ?. (string-to-char name)))
        (setq directory name)
        (setq last-type 'directory))
       ;; Has a weird prefix, so don't do anything.
       ((not (member prefix '("@ " "+ " "- " nil)))
        (setq last-type 'misc))
       ;; Either this is marked as a menu (@ prefix) or it is the
       ;; first item and it isn't a directory, so it has to be a
       ;; menu.
       ((or (null last-type)
            (string-equal "@ " prefix))
        (setq menu name)
        (setq last-type 'menu))
       ;; Append to directory.
       ((eq 'directory last-type)
        (setq directory (concat (file-name-as-directory directory) name)))
       ;; Append to menu.
       ((eq 'menu last-type)
        (setq menu (concat (file-name-as-directory menu) name))))
      (setq ancestry (cdr ancestry)))
    (when directory
      (setq directory (file-name-as-directory directory)))
    (list prefix name directory menu (or last-type 'misc))))

(defvar elxiki-context-format
  '(prefix name directory menu type))

(defun elxiki-context-create (&rest args)
  "Create a context with keyword args.
Mainly useful for testing. The keywords are:
:prefix    :: The prefix string of the final line.
:name      :: The rest of the final line.
:directory :: The directory for the context.
:menu      :: The menu the context was under.
:type      :: The context type ('directory, 'menu, or 'misc)"
  (let (prefix name directory menu type)
    (while (cdr args)
      (case (car args)
        (:prefix (setq prefix (cadr args)))
        (:name (setq name (cadr args)))
        (:directory (setq directory (cadr args)))
        (:menu (setq menu (cadr args)))
        (:type (setq type (cadr args))))
      (setq args (cddr args)))
    (list prefix name directory menu type)))

(defun elxiki-context-get-prefix (context)
  "Retrieve the prefix from CONTEXT."
  (nth 0 context))

(defun elxiki-context-get-name (context)
  "Retrieve the name from CONTEXT."
  (nth 1 context))

(defun elxiki-context-get-directory (context)
  "Retrieve the directory from CONTEXT."
  (or (nth 2 context) default-directory))

(defun elxiki-context-get-menu (context)
  "Retrieve the menu from CONTEXT."
  (nth 3 context))

(defun elxiki-context-get-type (context)
  "Return the type CONTEXT describes.
Can be 'directory, 'menu, or 'misc."
  (nth 4 context))

(defun elxiki-context-menu-root-p (context)
  "Return non-nil of CONTEXT describes a root level menu."
  (= 1 (length (split-string (elxiki-context-get-menu context) "/" 'noempty))))

(provide 'elxiki-context)
;;; elxiki-context.el ends here
