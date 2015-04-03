(ql:quickload :caveone)

(defmacro fn (body)
  `(lambda (%) ,body))

(defmacro fn2 (body)
  `(lambda (%1 %2) ,body))

(defmacro fn3 (body)
  `(lambda (%1 %2 %3) ,body))

(defmacro cmap (f &rest lst)
  `(mapcar ,f ,@lst))

(defmacro ->> (&body body)
  (reduce (fn2 (append %2 (list %1))) body))

(defmacro -> (&body body)
  (reduce (fn2 (append (list (first %2))
		       (list %1)
		       (rest %2)))
	  body))

(defpackage caveone.app
  (:use :cl)
  (:import-from :clack
                :call)
  (:import-from :clack.builder
                :builder)
  (:import-from :clack.middleware.static
                :<clack-middleware-static>)
  (:import-from :clack.middleware.session
                :<clack-middleware-session>)
  (:import-from :clack.middleware.accesslog
                :<clack-middleware-accesslog>)
  (:import-from :clack.middleware.backtrace
                :<clack-middleware-backtrace>)
  (:import-from :ppcre
                :scan
                :regex-replace)
  (:import-from :caveone.web
                :*web*)
  (:import-from :caveone.config
                :config
                :productionp
                :*static-directory*))

(in-package :caveone.app)

(builder
 (<clack-middleware-static>
  :path (lambda (path)
          (if (ppcre:scan
	       "^(?:/images/|/css/|/js/|/robot\\.txt$|/favicon.ico$)"
	       path)
              path
              nil))
  :root *static-directory*)
 (if (productionp)
     nil
     (make-instance '<clack-middleware-accesslog>))
 (if (getf (config) :error-log)
     (make-instance '<clack-middleware-backtrace>
                    :output (getf (config) :error-log))
     nil)
 <clack-middleware-session>
 (if (productionp)
     nil
     (lambda (app)
       (lambda (env)
         (let ((datafly:*trace-sql* t))
           (call app env)))))
 *web*)
