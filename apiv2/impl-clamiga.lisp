;;;; -*- indent-tabs-mode: nil -*-

;;;; CL-Amiga backend for bordeaux-threads API v2.
;;;; Uses the MP package provided by CL-Amiga's threading primitives.

(in-package :bordeaux-threads-2)

;;; CL-Amiga is always 32-bit (CL_Obj = uint32_t).
;;; Ensure :32-BIT is in *features* for atomics.lisp.
(eval-when (:compile-toplevel :load-toplevel :execute)
  #-(or 32-bit 64-bit)
  (pushnew :32-bit *features*))

;;;
;;; Threads
;;;

(deftype native-thread ()
  t)

(defun %make-thread (function name)
  (mp:make-thread function :name name))

(defun %current-thread ()
  (mp:current-thread))

(defun %thread-name (thread)
  (let ((name (mp:thread-name thread)))
    (if name (string name) nil)))

(defun %join-thread (thread)
  (mp:join-thread thread))

(defun %thread-yield ()
  (mp:thread-yield))

;;;
;;; Introspection/debugging
;;;

(defun %all-threads ()
  (mp:all-threads))

(defun %interrupt-thread (thread function)
  (mp:interrupt-thread thread function))

(defun %destroy-thread (thread)
  (mp:destroy-thread thread))

(defun %thread-alive-p (thread)
  (mp:thread-alive-p thread))


;;;
;;; Non-recursive locks
;;;

(deftype native-lock () t)

(defun %make-lock (name)
  (mp:make-lock name))

(mark-not-implemented 'acquire-lock :timeout)
(defun %acquire-lock (lock waitp timeout)
  (when timeout
    (signal-not-implemented 'acquire-lock :timeout))
  (mp:acquire-lock lock waitp))

(defun %release-lock (lock)
  (mp:release-lock lock))

(mark-not-implemented 'with-lock-held :timeout)
(defmacro %with-lock ((place timeout) &body body)
  (if timeout
      `(signal-not-implemented 'with-lock-held :timeout)
      `(mp:with-lock-held (,place) ,@body)))


;;;
;;; Recursive locks
;;; Note: CL-Amiga does not have true recursive locks.
;;; make-recursive-lock creates a regular lock.
;;;

(deftype native-recursive-lock () t)

(defun %make-recursive-lock (name)
  (mp:make-recursive-lock name))

(mark-not-implemented 'acquire-recursive-lock :timeout)
(defun %acquire-recursive-lock (lock waitp timeout)
  (when timeout
    (signal-not-implemented 'acquire-recursive-lock :timeout))
  (mp:acquire-lock lock waitp))

(defun %release-recursive-lock (lock)
  (mp:release-lock lock))

(mark-not-implemented 'with-recursive-lock-held :timeout)
(defmacro %with-recursive-lock ((place timeout) &body body)
  (if timeout
      `(signal-not-implemented 'with-recursive-lock-held :timeout)
      `(mp:with-lock-held (,place) ,@body)))


;;;
;;; Condition variables
;;;

(deftype condition-variable ()
  t)

(defun %make-condition-variable (name)
  (mp:make-condition-variable name))

(defun %condition-wait (cv lock timeout)
  (if timeout
      (mp:condition-wait cv lock timeout)
      (mp:condition-wait cv lock)))

(defun %condition-notify (cv)
  (mp:condition-notify cv))

(defun %condition-broadcast (cv)
  (mp:condition-broadcast cv))
