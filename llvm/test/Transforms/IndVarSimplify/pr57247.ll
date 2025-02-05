; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=indvars < %s | FileCheck %s

; We must NOT replace check against IV with check against invariant 0. It should fail.
define i32 @test() {
; CHECK-LABEL: @test(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[OUTER_LOOP:%.*]]
; CHECK:       outer.loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[IV_NEXT:%.*]], [[OUTER_LATCH:%.*]] ]
; CHECK-NEXT:    [[CHECK_1:%.*]] = icmp ult i32 [[IV]], 2
; CHECK-NEXT:    br label [[INNER_LOOP:%.*]]
; CHECK:       inner.loop:
; CHECK-NEXT:    [[STOREMERGE611_I:%.*]] = phi i64 [ 0, [[OUTER_LOOP]] ], [ [[ADD_I:%.*]], [[INNER_LATCH:%.*]] ]
; CHECK-NEXT:    br i1 [[CHECK_1]], label [[INNER_LATCH]], label [[EXIT:%.*]]
; CHECK:       inner.latch:
; CHECK-NEXT:    [[ADD_I]] = add nuw nsw i64 [[STOREMERGE611_I]], 1
; CHECK-NEXT:    [[CMP5_I:%.*]] = icmp ult i64 [[STOREMERGE611_I]], 11
; CHECK-NEXT:    br i1 [[CMP5_I]], label [[INNER_LOOP]], label [[OUTER_LATCH]]
; CHECK:       outer.latch:
; CHECK-NEXT:    [[IV_NEXT]] = add nsw i32 [[IV]], -1
; CHECK-NEXT:    br label [[OUTER_LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[IV_LCSSA:%.*]] = phi i32 [ [[IV]], [[INNER_LOOP]] ]
; CHECK-NEXT:    ret i32 [[IV_LCSSA]]
;
entry:
  br label %outer.loop

outer.loop:                                       ; preds = %outer.latch, %entry
  %iv = phi i32 [ 0, %entry ], [ %iv.next, %outer.latch ]
  %check_1 = icmp ult i32 %iv, 2
  br label %inner.loop

inner.loop:                                       ; preds = %inner.latch, %outer.loop
  %storemerge611.i = phi i64 [ 0, %outer.loop ], [ %add.i, %inner.latch ]
  br i1 %check_1, label %inner.latch, label %exit

inner.latch:                                      ; preds = %inner.loop
  %add.i = add i64 %storemerge611.i, 1
  %cmp5.i = icmp ult i64 %storemerge611.i, 11
  br i1 %cmp5.i, label %inner.loop, label %outer.latch

outer.latch:                                      ; preds = %inner.latch
  %iv.next = add i32 %iv, -1
  br label %outer.loop

exit:                                             ; preds = %inner.loop
  ret i32 %iv
}
