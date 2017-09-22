#|
 This file is a part of Radiance
 (c) 2014 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.radiance.core)

(define-interface mail
  (defun send (to subject message))
  (define-hook send (to subject message)))

(define-interface ban
  (defun jail (ip &key duration))
  (defun list ())
  (defun jail-time (&optional (ip (remote *request*))))
  (defun release (ip)))

(define-interface rate
  (defmacro define-limit (name (time-left &key (timeout 60) (limit 1)) &body on-limit-exceeded))
  (defun left (rate &key (ip (remote *request*))))
  (defmacro with-limitation ((limit) &body body)))

(define-interface admin
  (define-resource-locator page (&optional category panel &rest args))
  (defun list-panels ())
  (defun remove-panel (category name))
  (defmacro define-panel (category name options &body body))
  (define-option-type panel))

(define-interface cache
  (defun get (name))
  (defun renew (name))
  (defmacro with-cache (name-form test-form &body request-generator)))

(define-interface auth
  (defvar *login-timeout* (* 60 60 24 365))
  (define-resource-locator page (name &rest args))
  (defun current (&optional default session))
  (defun associate (user &optional session))
  (define-hook associate (session)))

(define-interface session
  (defvar *default-timeout* (* 60 60 24))
  (defclass session () ())
  (defun = (session-a session-b))
  (defun start ())
  (defun get (&optional session-id))
  (defun list ())
  (defun id (&optional session))
  (defun field (session/field &optional field))
  (defun (setf field) (value session/field &optional field))
  (defun timeout (&optional session))
  (defun (setf timeout) (seconds &optional session))
  (defun end (&optional session))
  (defun active-p (&optional session))
  (define-hook create (session)))

(define-interface user
  (define-condition condition (radiance-condition)
    ())
  (define-condition not-found (error condition)
    ((name :initarg :name :initform (error "NAME required."))))
  (defclass user () ())
  (defun = (user-a user-b))
  (defun list ())
  (defun get (username &key (if-does-not-exist NIL)))
  (defun username (user))
  (defun fields (user))
  (defun field (field user))
  (defun (setf field) (value field user))
  (defun remove-field (field user))
  (defun remove (user))
  (defun check (user branch))
  (defun grant (user &rest branches))
  (defun revoke (user &rest branches))
  (defun add-default-permissions (&rest branch))
  (defun action (user action public))
  (defun actions (user n &key (public T) oldest-first))
  (define-hook create (user))
  (define-hook remove (user))
  (define-hook action (user action public))
  (define-hook-switch ready unready ()))

(define-interface profile
  (define-resource-locator page (user &optional tab))
  (defun avatar (user size))
  (defun name (user))
  (defun fields ())
  (defun add-field (name &key (type :text) default (editable T)))
  (defun remove-field (name))
  (defun list-panels ())
  (defun remove-panel (name))
  (defmacro define-panel (name options &body body))
  (define-option-type panel))

(define-interface server
  (defun start (name &key))
  (defun stop (name))
  (defun listeners ())
  (define-hook-switch started stopped (name &key)))

(define-interface (logger l)
  (defun log (level category log-string &rest format-args))
  (defun trace (category log-string &rest format-args))
  (defun debug (category log-string &rest format-args))
  (defun info (category log-string &rest format-args))
  (defun warn (category log-string &rest format-args))
  (defun error (category log-string &rest format-args))
  (defun severe (category log-string &rest format-args))
  (defun fatal (category log-string &rest format-args)))

(define-interface (database db)
  (define-condition condition (radiance-condition)
    ((database :initarg :database :initform (error "DATABASE required."))))
  (define-condition connection-failed (error condition)
    ())
  (define-condition connection-already-open (warning condition)
    ())
  (define-condition collection-condition (condition)
    ((collection :initarg :collection :initform (error "COLLECTION required."))))
  (define-condition invalid-collection (error collection-condition)
    ())
  (define-condition collection-already-exists (error collection-condition)
    ())
  (define-condition invalid-field (error condition)
    ((field :initarg :field :initform (error "FIELD required."))))
  (deftype id ())
  (defun ensure-id (id-ish))
  (defun connect (database-name))
  (defun disconnect ())
  (defun connected-p ())
  (defun collections ())
  (defun collection-exists-p (collection))
  (defun create (collection structure &key indices (if-exists :ignore)))
  (defun structure (collection))
  (defun empty (collection))
  (defun drop (collection))
  (defun iterate (collection query function &key fields (skip 0) amount sort accumulate))
  (defun select (collection query &key fields (skip 0) amount sort))
  (defun count (collection query))
  (defun insert (collection data))
  (defun remove (collection query &key (skip 0) amount sort))
  (defun update (collection query data &key (skip 0) amount sort))
  (defmacro with-transaction (() &body body))
  (defmacro query (query-form))
  (define-hook-switch connected disconnected (name)))
