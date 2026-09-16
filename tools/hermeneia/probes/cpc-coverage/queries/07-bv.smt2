(set-logic ALL)
(declare-const v (_ BitVec 8))
(assert (= (bvand v (_ bv0 8)) (_ bv1 8)))
(check-sat)
