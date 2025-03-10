;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s -all -o %t.text.wast -g -S
;; RUN: wasm-as %s -all -g -o %t.wasm
;; RUN: wasm-dis %t.wasm -all -o %t.bin.wast
;; RUN: wasm-as %s -all -o %t.nodebug.wasm
;; RUN: wasm-dis %t.nodebug.wasm -all -o %t.bin.nodebug.wast
;; RUN: cat %t.text.wast | filecheck %s --check-prefix=CHECK-TEXT
;; RUN: cat %t.bin.wast | filecheck %s --check-prefix=CHECK-BIN
;; RUN: cat %t.bin.nodebug.wast | filecheck %s --check-prefix=CHECK-BIN-NODEBUG

(module
  ;; CHECK-TEXT:      (type $0 (func))

  ;; CHECK-TEXT:      (type $1 (func (param i32 f64) (result i32)))

  ;; CHECK-TEXT:      (import "env" "table" (table $timport$0 9 9 funcref))
  ;; CHECK-BIN:      (type $0 (func))

  ;; CHECK-BIN:      (type $1 (func (param i32 f64) (result i32)))

  ;; CHECK-BIN:      (import "env" "table" (table $timport$0 9 9 funcref))
  ;; CHECK-BIN-NODEBUG:      (type $0 (func))

  ;; CHECK-BIN-NODEBUG:      (type $1 (func (param i32 f64) (result i32)))

  ;; CHECK-BIN-NODEBUG:      (import "env" "table" (table $timport$0 9 9 funcref))
  (import "env" "table" (table 9 9 funcref))

  ;; CHECK-TEXT:      (export "call_indirect" (func $call_indirect))

  ;; CHECK-TEXT:      (func $call_indirect (type $0)
  ;; CHECK-TEXT-NEXT:  (drop
  ;; CHECK-TEXT-NEXT:   (call_indirect $timport$0 (type $1)
  ;; CHECK-TEXT-NEXT:    (i32.const 10)
  ;; CHECK-TEXT-NEXT:    (f64.const 20)
  ;; CHECK-TEXT-NEXT:    (i32.const 30)
  ;; CHECK-TEXT-NEXT:   )
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT:  (call_indirect $timport$0 (type $0)
  ;; CHECK-TEXT-NEXT:   (i32.const 1)
  ;; CHECK-TEXT-NEXT:  )
  ;; CHECK-TEXT-NEXT: )
  ;; CHECK-BIN:      (export "call_indirect" (func $call_indirect))

  ;; CHECK-BIN:      (func $call_indirect (type $0)
  ;; CHECK-BIN-NEXT:  (drop
  ;; CHECK-BIN-NEXT:   (call_indirect $timport$0 (type $1)
  ;; CHECK-BIN-NEXT:    (i32.const 10)
  ;; CHECK-BIN-NEXT:    (f64.const 20)
  ;; CHECK-BIN-NEXT:    (i32.const 30)
  ;; CHECK-BIN-NEXT:   )
  ;; CHECK-BIN-NEXT:  )
  ;; CHECK-BIN-NEXT:  (call_indirect $timport$0 (type $0)
  ;; CHECK-BIN-NEXT:   (i32.const 1)
  ;; CHECK-BIN-NEXT:  )
  ;; CHECK-BIN-NEXT: )
  (func $call_indirect (export "call_indirect")
    (drop
      (call_indirect (param i32) (param f64) (result i32) (i32.const 10) (f64.const 20) (i32.const 30))
    )
    (call_indirect (i32.const 1))
  )
)
;; CHECK-BIN-NODEBUG:      (export "call_indirect" (func $0))

;; CHECK-BIN-NODEBUG:      (func $0 (type $0)
;; CHECK-BIN-NODEBUG-NEXT:  (drop
;; CHECK-BIN-NODEBUG-NEXT:   (call_indirect $timport$0 (type $1)
;; CHECK-BIN-NODEBUG-NEXT:    (i32.const 10)
;; CHECK-BIN-NODEBUG-NEXT:    (f64.const 20)
;; CHECK-BIN-NODEBUG-NEXT:    (i32.const 30)
;; CHECK-BIN-NODEBUG-NEXT:   )
;; CHECK-BIN-NODEBUG-NEXT:  )
;; CHECK-BIN-NODEBUG-NEXT:  (call_indirect $timport$0 (type $0)
;; CHECK-BIN-NODEBUG-NEXT:   (i32.const 1)
;; CHECK-BIN-NODEBUG-NEXT:  )
;; CHECK-BIN-NODEBUG-NEXT: )
