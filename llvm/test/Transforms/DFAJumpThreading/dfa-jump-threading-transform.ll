; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -passes=dfa-jump-threading %s | FileCheck %s

; These tests check that the DFA jump threading transformation is applied
; properly to two CFGs. It checks that blocks are cloned, branches are updated,
; and SSA form is restored.
define i32 @test1(i32 %num) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[COUNT:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[INC:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[STATE:%.*]] = phi i32 [ 1, [[ENTRY]] ], [ poison, [[FOR_INC]] ]
; CHECK-NEXT:    switch i32 [[STATE]], label [[FOR_INC_JT1:%.*]] [
; CHECK-NEXT:      i32 1, label [[CASE1:%.*]]
; CHECK-NEXT:      i32 2, label [[CASE2:%.*]]
; CHECK-NEXT:    ]
; CHECK:       for.body.jt2:
; CHECK-NEXT:    [[COUNT_JT2:%.*]] = phi i32 [ [[INC_JT2:%.*]], [[FOR_INC_JT2:%.*]] ]
; CHECK-NEXT:    [[STATE_JT2:%.*]] = phi i32 [ [[STATE_NEXT_JT2:%.*]], [[FOR_INC_JT2]] ]
; CHECK-NEXT:    br label [[CASE2]]
; CHECK:       for.body.jt1:
; CHECK-NEXT:    [[COUNT_JT1:%.*]] = phi i32 [ [[INC_JT1:%.*]], [[FOR_INC_JT1]] ]
; CHECK-NEXT:    [[STATE_JT1:%.*]] = phi i32 [ [[STATE_NEXT_JT1:%.*]], [[FOR_INC_JT1]] ]
; CHECK-NEXT:    br label [[CASE1]]
; CHECK:       case1:
; CHECK-NEXT:    [[COUNT2:%.*]] = phi i32 [ [[COUNT_JT1]], [[FOR_BODY_JT1:%.*]] ], [ [[COUNT]], [[FOR_BODY]] ]
; CHECK-NEXT:    br label [[FOR_INC_JT2]]
; CHECK:       case2:
; CHECK-NEXT:    [[COUNT1:%.*]] = phi i32 [ [[COUNT_JT2]], [[FOR_BODY_JT2:%.*]] ], [ [[COUNT]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[COUNT1]], 50
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_INC_JT1]], label [[SI_UNFOLD_FALSE:%.*]]
; CHECK:       si.unfold.false:
; CHECK-NEXT:    br label [[FOR_INC_JT2]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INC]] = add nsw i32 undef, 1
; CHECK-NEXT:    [[CMP_EXIT:%.*]] = icmp slt i32 [[INC]], [[NUM:%.*]]
; CHECK-NEXT:    br i1 [[CMP_EXIT]], label [[FOR_BODY]], label [[FOR_END:%.*]]
; CHECK:       for.inc.jt2:
; CHECK-NEXT:    [[COUNT4:%.*]] = phi i32 [ [[COUNT1]], [[SI_UNFOLD_FALSE]] ], [ [[COUNT2]], [[CASE1]] ]
; CHECK-NEXT:    [[STATE_NEXT_JT2]] = phi i32 [ 2, [[CASE1]] ], [ 2, [[SI_UNFOLD_FALSE]] ]
; CHECK-NEXT:    [[INC_JT2]] = add nsw i32 [[COUNT4]], 1
; CHECK-NEXT:    [[CMP_EXIT_JT2:%.*]] = icmp slt i32 [[INC_JT2]], [[NUM]]
; CHECK-NEXT:    br i1 [[CMP_EXIT_JT2]], label [[FOR_BODY_JT2]], label [[FOR_END]]
; CHECK:       for.inc.jt1:
; CHECK-NEXT:    [[COUNT3:%.*]] = phi i32 [ [[COUNT1]], [[CASE2]] ], [ [[COUNT]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[STATE_NEXT_JT1]] = phi i32 [ 1, [[CASE2]] ], [ 1, [[FOR_BODY]] ]
; CHECK-NEXT:    [[INC_JT1]] = add nsw i32 [[COUNT3]], 1
; CHECK-NEXT:    [[CMP_EXIT_JT1:%.*]] = icmp slt i32 [[INC_JT1]], [[NUM]]
; CHECK-NEXT:    br i1 [[CMP_EXIT_JT1]], label [[FOR_BODY_JT1]], label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret i32 0
;
entry:
  br label %for.body

for.body:
  %count = phi i32 [ 0, %entry ], [ %inc, %for.inc ]
  %state = phi i32 [ 1, %entry ], [ %state.next, %for.inc ]
  switch i32 %state, label %for.inc [
  i32 1, label %case1
  i32 2, label %case2
  ]

case1:
  br label %for.inc

case2:
  %cmp = icmp eq i32 %count, 50
  %sel = select i1 %cmp, i32 1, i32 2
  br label %for.inc

for.inc:
  %state.next = phi i32 [ %sel, %case2 ], [ 1, %for.body ], [ 2, %case1 ]
  %inc = add nsw i32 %count, 1
  %cmp.exit = icmp slt i32 %inc, %num
  br i1 %cmp.exit, label %for.body, label %for.end

for.end:
  ret i32 0
}


define i32 @test2(i32 %init) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[INIT:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_1:%.*]], label [[SI_UNFOLD_FALSE1:%.*]]
; CHECK:       si.unfold.false:
; CHECK-NEXT:    br label [[LOOP_1]]
; CHECK:       si.unfold.false.jt2:
; CHECK-NEXT:    br label [[LOOP_1_JT2:%.*]]
; CHECK:       si.unfold.false.jt4:
; CHECK-NEXT:    br label [[LOOP_1_JT4:%.*]]
; CHECK:       si.unfold.false1:
; CHECK-NEXT:    br label [[LOOP_1]]
; CHECK:       loop.1:
; CHECK-NEXT:    [[STATE_1:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ undef, [[SI_UNFOLD_FALSE:%.*]] ], [ 2, [[SI_UNFOLD_FALSE1]] ]
; CHECK-NEXT:    br label [[LOOP_2:%.*]]
; CHECK:       loop.1.jt2:
; CHECK-NEXT:    [[STATE_1_JT2:%.*]] = phi i32 [ [[STATE_1_BE_JT2:%.*]], [[SI_UNFOLD_FALSE_JT2:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_2_JT2:%.*]]
; CHECK:       loop.1.jt4:
; CHECK-NEXT:    [[STATE_1_JT4:%.*]] = phi i32 [ [[STATE_1_BE_JT4:%.*]], [[SI_UNFOLD_FALSE_JT4:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_2_JT4:%.*]]
; CHECK:       loop.1.jt1:
; CHECK-NEXT:    [[STATE_1_JT1:%.*]] = phi i32 [ 1, [[LOOP_1_BACKEDGE:%.*]] ], [ 1, [[LOOP_1_BACKEDGE_JT4:%.*]] ], [ 1, [[LOOP_1_BACKEDGE_JT2:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_2_JT1:%.*]]
; CHECK:       loop.2:
; CHECK-NEXT:    [[STATE_2:%.*]] = phi i32 [ [[STATE_1]], [[LOOP_1]] ], [ poison, [[LOOP_2_BACKEDGE:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_3:%.*]]
; CHECK:       loop.2.jt2:
; CHECK-NEXT:    [[STATE_2_JT2:%.*]] = phi i32 [ [[STATE_1_JT2]], [[LOOP_1_JT2]] ]
; CHECK-NEXT:    br label [[LOOP_3_JT2:%.*]]
; CHECK:       loop.2.jt3:
; CHECK-NEXT:    [[STATE_2_JT3:%.*]] = phi i32 [ [[STATE_2_BE_JT3:%.*]], [[LOOP_2_BACKEDGE_JT3:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_3_JT3:%.*]]
; CHECK:       loop.2.jt0:
; CHECK-NEXT:    [[STATE_2_JT0:%.*]] = phi i32 [ [[STATE_2_BE_JT0:%.*]], [[LOOP_2_BACKEDGE_JT0:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_3_JT0:%.*]]
; CHECK:       loop.2.jt4:
; CHECK-NEXT:    [[STATE_2_JT4:%.*]] = phi i32 [ [[STATE_1_JT4]], [[LOOP_1_JT4]] ]
; CHECK-NEXT:    br label [[LOOP_3_JT4:%.*]]
; CHECK:       loop.2.jt1:
; CHECK-NEXT:    [[STATE_2_JT1:%.*]] = phi i32 [ [[STATE_1_JT1]], [[LOOP_1_JT1:%.*]] ]
; CHECK-NEXT:    br label [[LOOP_3_JT1:%.*]]
; CHECK:       loop.3:
; CHECK-NEXT:    [[STATE:%.*]] = phi i32 [ [[STATE_2]], [[LOOP_2]] ]
; CHECK-NEXT:    switch i32 [[STATE]], label [[INFLOOP_I:%.*]] [
; CHECK-NEXT:      i32 2, label [[CASE2:%.*]]
; CHECK-NEXT:      i32 3, label [[CASE3:%.*]]
; CHECK-NEXT:      i32 4, label [[CASE4:%.*]]
; CHECK-NEXT:      i32 0, label [[CASE0:%.*]]
; CHECK-NEXT:      i32 1, label [[CASE1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       loop.3.jt2:
; CHECK-NEXT:    [[STATE_JT2:%.*]] = phi i32 [ [[STATE_2_JT2]], [[LOOP_2_JT2]] ]
; CHECK-NEXT:    br label [[CASE2]]
; CHECK:       loop.3.jt0:
; CHECK-NEXT:    [[STATE_JT0:%.*]] = phi i32 [ [[STATE_2_JT0]], [[LOOP_2_JT0:%.*]] ]
; CHECK-NEXT:    br label [[CASE0]]
; CHECK:       loop.3.jt4:
; CHECK-NEXT:    [[STATE_JT4:%.*]] = phi i32 [ [[STATE_2_JT4]], [[LOOP_2_JT4]] ]
; CHECK-NEXT:    br label [[CASE4]]
; CHECK:       loop.3.jt1:
; CHECK-NEXT:    [[STATE_JT1:%.*]] = phi i32 [ [[STATE_2_JT1]], [[LOOP_2_JT1]] ]
; CHECK-NEXT:    br label [[CASE1]]
; CHECK:       loop.3.jt3:
; CHECK-NEXT:    [[STATE_JT3:%.*]] = phi i32 [ 3, [[CASE2]] ], [ [[STATE_2_JT3]], [[LOOP_2_JT3:%.*]] ]
; CHECK-NEXT:    br label [[CASE3]]
; CHECK:       case2:
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_3_JT3]], label [[LOOP_1_BACKEDGE_JT4]]
; CHECK:       case3:
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_2_BACKEDGE_JT0]], label [[CASE4]]
; CHECK:       case4:
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_2_BACKEDGE_JT3]], label [[LOOP_1_BACKEDGE_JT2]]
; CHECK:       loop.1.backedge:
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_1_JT1]], label [[SI_UNFOLD_FALSE]]
; CHECK:       loop.1.backedge.jt2:
; CHECK-NEXT:    [[STATE_1_BE_JT2]] = phi i32 [ 2, [[CASE4]] ]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_1_JT1]], label [[SI_UNFOLD_FALSE_JT2]]
; CHECK:       loop.1.backedge.jt4:
; CHECK-NEXT:    [[STATE_1_BE_JT4]] = phi i32 [ 4, [[CASE2]] ]
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP_1_JT1]], label [[SI_UNFOLD_FALSE_JT4]]
; CHECK:       loop.2.backedge:
; CHECK-NEXT:    br label [[LOOP_2]]
; CHECK:       loop.2.backedge.jt3:
; CHECK-NEXT:    [[STATE_2_BE_JT3]] = phi i32 [ 3, [[CASE4]] ]
; CHECK-NEXT:    br label [[LOOP_2_JT3]]
; CHECK:       loop.2.backedge.jt0:
; CHECK-NEXT:    [[STATE_2_BE_JT0]] = phi i32 [ 0, [[CASE3]] ]
; CHECK-NEXT:    br label [[LOOP_2_JT0]]
; CHECK:       case0:
; CHECK-NEXT:    br label [[EXIT:%.*]]
; CHECK:       case1:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       infloop.i:
; CHECK-NEXT:    br label [[INFLOOP_I]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 0
;
entry:
  %cmp = icmp eq i32 %init, 0
  %sel = select i1 %cmp, i32 0, i32 2
  br label %loop.1

loop.1:
  %state.1 = phi i32 [ %sel, %entry ], [ %state.1.be2, %loop.1.backedge ]
  br label %loop.2

loop.2:
  %state.2 = phi i32 [ %state.1, %loop.1 ], [ %state.2.be, %loop.2.backedge ]
  br label %loop.3

loop.3:
  %state = phi i32 [ %state.2, %loop.2 ], [ 3, %case2 ]
  switch i32 %state, label %infloop.i [
  i32 2, label %case2
  i32 3, label %case3
  i32 4, label %case4
  i32 0, label %case0
  i32 1, label %case1
  ]

case2:
  br i1 %cmp, label %loop.3, label %loop.1.backedge

case3:
  br i1 %cmp, label %loop.2.backedge, label %case4

case4:
  br i1 %cmp, label %loop.2.backedge, label %loop.1.backedge

loop.1.backedge:
  %state.1.be = phi i32 [ 2, %case4 ], [ 4, %case2 ]
  %state.1.be2 = select i1 %cmp, i32 1, i32 %state.1.be
  br label %loop.1

loop.2.backedge:
  %state.2.be = phi i32 [ 3, %case4 ], [ 0, %case3 ]
  br label %loop.2

case0:
  br label %exit

case1:
  br label %exit

infloop.i:
  br label %infloop.i

exit:
  ret i32 0
}

define void @pr78059_bitwidth(i1 %c) {
; CHECK-LABEL: @pr78059_bitwidth(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[DOTSPLIT_PREHEADER:%.*]], label [[DOTSPLIT_PREHEADER]]
; CHECK:       .split.preheader:
; CHECK-NEXT:    br label [[DOTSPLIT:%.*]]
; CHECK:       .split:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i128 [ 0, [[DOTSPLIT_PREHEADER]] ]
; CHECK-NEXT:    switch i128 [[TMP0]], label [[END:%.*]] [
; CHECK-NEXT:      i128 -1, label [[END]]
; CHECK-NEXT:      i128 0, label [[DOTSPLIT_JT18446744073709551615:%.*]]
; CHECK-NEXT:    ]
; CHECK:       .split.jt18446744073709551615:
; CHECK-NEXT:    [[TMP1:%.*]] = phi i128 [ -1, [[DOTSPLIT]] ]
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    ret void
;
entry:
  br i1 %c, label %.split.preheader, label %.split.preheader

.split.preheader:
  br label %.split

.split:
  %0 = phi i128 [ 0, %.split.preheader ], [ -1, %.split ]
  switch i128 %0, label %end [
  i128 -1, label %end
  i128 0, label %.split
  ]

end:
  ret void
}
