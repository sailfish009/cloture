;;; -*- mode: clojure -*-
;;; This file is the bootstrapping inflection point -- it contains
;;; implementations of clojure.core functions written in Clojure.

(in-package "clojure.core")
(named-readtables:in-readtable cloture:cloture)

(defn nil?
  ([x] (identical? x nil)))

(defn true?
  ([x] (identical? x true)))

(defn false?
  ([x] (identical? x false)))

(defn identity [x] x)

(defmacro when [test & body]
  `(if ~test (do ~@body)))

(defmacro when-not [test & body]
  `(when (not ~test) ~@body))

(defmacro if-not
  ([test then] `(if (not ~test) ~then))
  ([test then else] `(if (not ~test) ~then ~else)))

(defmacro and [& forms]
  (if (seq forms)
    `(let [val# ~(first forms)]
       (if-not val# val#
               (and ~@(rest forms))))
    true))

(defmacro or [& forms]
  (if (seq forms)
    `(let [val# ~(first forms)]
       (if val# val#
           (or ~@(rest forms))))
    nil))

(defn conj
  ([coll x] (-conj coll x))
  ([coll x & xs] (reduce -conj coll (cons x xs))))

(defn dissoc
  ([coll k] (-dissoc coll k []))
  ([coll k & ks] (-dissoc coll k ks)))

(defn not= [& xs]
  (not (apply = xs)))

(defn get
  ([map k] (get map k nil))
  ([map k not-found] (lookup map k not-found)))

(defn empty? [xs]
  (not (seq xs)))

(defmacro if-let
  ([binds then] `(if-let ~binds ~then nil))
  ([[binds test] then else]
   `(let [temp# ~test]
      (if temp#
        (let [~binds temp#]
          ~then)
        ~else))))

(defmacro when-let
  ([binds & body]
   `(if-let ~binds ~@body)))

(defn fnil
  ([f x]
   (fn [arg1 & args]
     (apply f
            (if (nil? arg1) x arg1)
            args)))
  ([f x y]
   (fn [arg1 arg2 & args]
     (apply f
            (if (nil? arg1) x arg1)
            (if (nil? arg2) y arg2)
            args)))
  ([f x y z]
   (fn [arg1 arg2 arg3 & args]
     (apply f
            (if (nil? arg1) x arg1)
            (if (nil? arg2) y arg2)
            (if (nil? arg3) z arg3)
            args))))

(defn nthnext [coll n]
  (if (zero? n)
    (seq coll)
    (recur (next coll) (dec n))))

(defn nthrest [coll n]
  (if (zero? n)
    (seq coll)
    (recur (rest coll) (dec n))))

(defn get-in
  ([m ks] (get-in m ks nil))
  ([m ks not-found]
   (loop [m m ks ks]
     (if (not (seq ks)) m
         (let [ks (first ks)
               ks (rest ks)]
           (recur (lookup m ks not-found) ks))))))

(defn into
  ([] [])
  ([to] to)
  ([to from]
   (apply conj to (seq from))))