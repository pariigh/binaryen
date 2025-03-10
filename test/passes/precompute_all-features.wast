(module
  (memory 512 512
   (data "hello!")
  )
  (type $0 (func (param i32)))
  (global $global i32 (i32.const 1))
  (global $global-mut (mut i32) (i32.const 2))
  (func $x (type $0) (param $x i32)
    (call $x
      (i32.add
        (i32.const 100)
        (i32.const 2200)
      )
    )
    (drop
      (i32.add
        (i32.const 1)
        (i32.const 2)
      )
    )
    (drop
      (i32.add
        (i32.const 1)
        (local.get $x)
      )
    )
    (drop
      (i32.add
        (i32.const 1)
        (i32.add
          (i32.const 2)
          (i32.const 3)
        )
      )
    )
    (drop
      (i32.sub
        (i32.const 1)
        (i32.const 2)
      )
    )
    (drop
      (i32.sub
        (i32.add
          (i32.const 0)
          (i32.const 4)
        )
        (i32.const 1)
      )
    )
    (tuple.drop 2
     (tuple.make 2
      (tuple.extract 2 0
       (tuple.make 2
        (i32.const 42)
        (i32.const 0)
       )
      )
      (tuple.extract 2 1
       (tuple.make 2
        (i64.const 0)
        (i64.const 42)
       )
      )
     )
    )
    (loop $in
      (br $in)
    )
    (block $b
      (br_if $b (i32.const 0))
      (br_if $b (i32.const 1))
      (call $x (i32.const 4))
    )
    (block $c
      (br_if $c (i32.const 0))
      (call $x (i32.const 4))
      (br_if $c (i32.const 1))
      (br $c)
    )
    (drop
      (block $val (result i32)
        (drop (br_if $val (i32.const 100) (i32.const 0)))
        (call $x (i32.const 4))
        (drop (br_if $val (i32.const 101) (i32.const 1)))
        (br $val (i32.const 102))
      )
    )
    (block $d
      (block $e
        (br_if $d (br $e))
        (call $x (i32.const 4))
        (br_if $e (br $d))
      )
    )
    (drop
      (block $d (result i32)
        (call $x (i32.const 5))
        (block $e
          (drop (br_if $d (br $e) (i32.const 1)))
          (drop (br_if $d (br $e) (i32.const 0)))
          (drop (br_if $d (i32.const 1) (br $e)))
          (drop (br_if $d (i32.const 0) (br $e)))
          (unreachable)
        )
        (i32.const 1)
      )
    )
    (drop
      (block $d (result i32)
        (call $x (i32.const 6))
        (block $e
          (drop (br_if $d (br $e) (i32.const 0)))
          (drop (br_if $d (i32.const 1) (br $e)))
          (drop (br_if $d (i32.const 0) (br $e)))
          (unreachable)
        )
        (i32.const 1)
      )
    )
    (drop
      (block $d (result i32)
        (call $x (i32.const 7))
        (block $e
          (drop (br_if $d (i32.const 1) (br $e)))
        )
        (i32.const 2)
      )
    )
    (call $x
      (block $out (result i32)
        (block $waka1
          (block $waka2
            (block $waka3
              (br_table $waka1 $waka2 $waka3
                (i32.const 0)
              )
            )
            (br $out (i32.const 0))
          )
          (br $out (i32.const 1))
        )
        (br $out (i32.const 2))
      )
    )
    (call $x
      (block $out (result i32)
        (block $waka1
          (block $waka2
            (block $waka3
              (br_table $waka1 $waka2 $waka3
                (i32.const 1)
              )
            )
            (br $out (i32.const 0))
          )
          (br $out (i32.const 1))
        )
        (br $out (i32.const 2))
      )
    )
    (call $x
      (block $out (result i32)
        (block $waka1
          (block $waka2
            (block $waka3
              (br_table $waka1 $waka2 $waka3
                (i32.const 2)
              )
            )
            (br $out (i32.const 0))
          )
          (br $out (i32.const 1))
        )
        (br $out (i32.const 2))
      )
    )
    (call $x
      (block $out (result i32)
        (block $waka1
          (block $waka2
            (block $waka3
              (br_table $waka1 $waka2 $waka3
                (i32.const 3)
              )
            )
            (br $out (i32.const 0))
          )
          (br $out (i32.const 1))
        )
        (br $out (i32.const 2))
      )
    )
  )
  (func $ret (result i32)
    (if (call $ret)
      (return (i32.const 0))
    )
    (if (call $ret)
      (return (return (i32.const 1)))
    )
    (i32.const 1)
  )
  (func $noret
    (if (call $ret)
      (return)
    )
  )
  (func $refinalize-br-condition-unreachable
   (block $label$1
    (drop
     (br_if $label$1
      (unreachable)
     )
    )
   )
  )
  (func $br_if-condition-is-block-i32-but-unreachable-so-refinalize-tricky
   (drop
    (block $label$1 (result i32)
     (drop
      (br_if $label$1
       (i32.const 100)
       (block $label$3 (result i32)
        (unreachable)
       )
      )
     )
     (i32.const 0)
    )
   )
  )
  (func $reuse-br-value (result f64)
   (block $label$0 (result f64)
    (i32.store8
     (i32.const 1919623207)
     (if (result i32)
      (i32.const 1)
      (block $label$2 (result i32)
       (drop
        (i64.and
         (i64.trunc_f32_u
          (f32.const 70847791997969805621592064)
         )
         (i64.const 729618461987467893)
        )
       )
       (br_if $label$2
        (i32.const 2049535349)
        (f32.eq
         (f32.demote_f64
          (f64.mul
           (br_if $label$0 ;; this br is optimized, and br *and* values reused
            (f64.const 6.134856208230095e-154)
            (i32.const 690910817)
           )
           (f64.const 1.515470884183969e-152)
          )
         )
         (f32.const 66524025679377434935296)
        )
       )
      )
      (i32.load offset=3 align=2
        (i32.const 169901344)
      )
     )
    )
    (f64.const 4776014875438170098655851e156)
   )
  )
  (func $refinalize-two-breaks-one-unreachable
   (drop
    (block $label$0 (result i64)
     (br_if $label$0
      (select
       (i64.const 1)
       (block (result i64)
        (global.set $global-mut
         (i32.const 1)
        )
        (br_if $label$0
         (i64.const -22)
         (i32.const -1)
        )
       )
       (i32.const 0)
      )
      (i32.const 1)
     )
    )
   )
  )
  (func $one-break-value-and-it-is-unreachable (result f64)
   (local $var$0 i32)
   (block $label$6 (result f64)
    (br_if $label$6
     (unreachable)
     (i32.const 0)
    )
   )
  )
  (func $global-notprecomputable (result i32)
   (i32.add
    (i32.const 1)
    (global.get $global-mut)
   )
  )
  (func $global-precomputable (result i32)
   (i32.add
    (i32.const 1)
    (global.get $global)
   )
  )
  (func $global-partiallyprecomputable (result i32)
   (i32.sub
    (i32.add
     (i32.const 1)
     (global.get $global-mut)
    )
    (i32.add
     (i32.const 1)
     (global.get $global)
    )
   )
  )
  (func $simd-precompute (result v128)
   (i32x4.splat
    (i32.const 0)
   )
  )
  (func $no-memory-init-precompute
   (memory.init 0
    (i32.const 512)
    (i32.const 0)
    (i32.const 12)
   )
  )
  (func $no-data-drop-precompute
   (data.drop 0)
  )
  (func $no-memory-copy-precompute
   (memory.copy
    (i32.const 512)
    (i32.const 0)
    (i32.const 12)
   )
  )
  (func $no-memory-fill-precompute
   (memory.fill
    (i32.const 512)
    (i32.const 0)
    (i32.const 12)
   )
  )
  (func $tuple-precompute (result i32 i64)
   (tuple.make 2
    (tuple.extract 2 0
     (tuple.make 2
      (i32.const 42)
      (i32.const 0)
     )
    )
    (tuple.extract 2 1
     (tuple.make 2
      (i64.const 0)
      (i64.const 42)
     )
    )
   )
  )
  (func $loop-precompute (result i32)
   (block $block (result i32)
    (loop $loop
     (br $block (i32.const 1))
    )
   )
  )

  ;; Check if Precompute pass does not crash on reference types
  (func $reftype-test (result externref)
    (ref.null extern)
  )

  ;; Check if constant nodes (const, ref.null, and ref.func) are correctly
  ;; reused. (We shouldn't reuse a const node for something like ref.null, which
  ;; will incorrectly cause an expression like 'someref.const'.)
  (func $dummy)
  (func $br_reuse_node
   (drop
    (block $l0 (result f32)
     (drop
      (block $l1 (result i32)
       (global.set $global-mut
        (i32.const 1)
       )
       (br_if $l1
        (i32.const 1)
        (f32.lt
         (br_if $l0
          (f32.const 3.5)
          (i32.const 1)
         )
         (f32.const 3)
        )
       )
      )
     )
     (f32.const 0)
    )
   )

   (drop
    (block $l2 (result externref)
     (drop
      (block $l3 (result i32)
       (global.set $global-mut
        (i32.const 1)
       )
       (br_if $l3
        (i32.const 1)
        (ref.is_null
         (br_if $l2
          (ref.null extern)
          (i32.const 3)
         )
        )
       )
      )
     )
     (ref.null extern)
    )
   )

   (drop
    (block $l4 (result funcref)
     (drop
      (block $l5 (result i32)
       (global.set $global-mut
        (i32.const 1)
       )
       (br_if $l5
        (i32.const 1)
        (ref.is_null
         (br_if $l4
          (ref.func $dummy)
          (i32.const 3)
         )
        )
       )
      )
     )
     (ref.null func)
    )
   )
  )
)
