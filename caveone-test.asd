(in-package :cl-user)
(defpackage caveone-test-asd
  (:use :cl :asdf))
(in-package :caveone-test-asd)

(defsystem caveone-test
  :author "SQuest (Sabda PS)"
  :license ""
  :depends-on (:caveone
               :prove)
  :components ((:module "t"
                :components
                ((:file "caveone"))))
  :perform (load-op :after (op c) (asdf:clear-system c)))
