(defpackage :cloture.test
  (:use :cl :alexandria :serapeum :fiveam :cloture :named-readtables)
  (:import-from :fset :equal? :seq :convert)
  (:shadowing-import-from :fset :map))
(in-package :cloture.test)

(def-suite cloture)
(in-suite cloture)

(defun run-cloture-tests ()
  (run! 'cloture))

(defun clj (string)
  (with-input-from-string (in string)
    (read-clojure in)))

(defun clj! (s)
  (eval (clj s)))

(test read-vector
  (is (equal? (seq 1 2 3 :x)
              (clj "[1 2 3 :X]"))))

(test read-map
  (is (equal? (map (:x 1) (:y 2) (:z 3))
              (clj "{:X 1 :Y 2 :Z 3}"))))

(test read-meta
  (let ((sym (clj "^:dynamic *bar*")))
    (is (symbolp sym))
    (is-true (meta-ref sym :|dynamic|))))

(test let
  (is (= 3
         (eval
          (clj "(let [x 1 y 2] (+ x y))")))))

(test commas
  (is (equal '(:x :y :z) (clj "(:X, :Y, :Z)"))))

(test qq
  (is (equal '(:x) (eval (clj "`(~:X)")))))

(test reader-conditional
  (is (null (clj "#?(:clj 1)")))
  (is (eql 1 (clj "#?(:cl 1 :clj 2)"))))

(test destructure
  (is (equal '(1 2 3) (clj! "(let ([x y z] [1 2 3]) (list x y z))")))
  (is (equal '(1 2 3) (clj! "(let ([x y z] '(1 2 3)) (list x y z))")))

  (is (equal '(1 2 3)
             (convert 'list
                      (clj! "(let ([_ _ _ :as all] [1 2 3]) all)"))))
  (is (equal '(1 2 3)
             (convert 'list
                      (clj! "(let ([_ _ _ :as all] '(1 2 3)) all)"))))

  (is (equal '(2 3) (clj! "(let ([_ & ys] [1 2 3]) ys)")))
  (is (equal '(2 3) (clj! "(let ([_ & ys] '(1 2 3)) ys)")))

  (is (equal '(1 2 3)
             (convert 'list
                      (clj! "(let ([_ & ys :as all] [1 2 3]) all)"))))
  (is (equal '(1 2 3)
             (convert 'list
                      (clj! "(let ([_ & ys :as all] '(1 2 3)) all)"))))

  (is (equal '(1 2 3 4 5 6)
             (clj! "(let ([[a] [[b]] c [x y z]] [[1] [[2]] 3 [4 5 6]]) (list a b c x y z))"))))