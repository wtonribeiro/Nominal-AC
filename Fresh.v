(*
 ============================================================================
 Project     : Nominal A and AC Equivalence
 File        : Fresh.v
 Authors     : Washington Luís R. de Carvalho Segundo and
               Mauricio Ayala Rincón 
               Universidade de Brasilia (UnB) - Brazil
               Group of Theory of Computation
 
 Last Modified On: April 15, 2016.
 ============================================================================
 *)

Require Import Tuples.
Require Export Disagr.

Definition Context := set (Atom * Var).

Inductive fresh : Context -> Atom -> term -> Prop :=

 | fresh_Ut   : forall C a, fresh C a Ut 

 | fresh_Pr   : forall C a t1 t2, (fresh C a t1) -> (fresh C a t2) -> 
                                  (fresh C a (<|t1,t2|>))  

 | fresh_Fc   : forall C a E n t, (fresh C a t) -> 
                               (fresh C a (Fc E n t))

 | fresh_Ab_1 : forall C a t, fresh C a (Ab a t)

 | fresh_Ab_2 : forall C a a' t, a <> a' -> (fresh C a t) -> 
                                 (fresh C a (Ab a' t))

 | fresh_At   : forall C a a', a <> a' -> 
                               (fresh C a (At a'))

 | fresh_Su   : forall C p a X, set_In (((!p $ a), X)) C -> 
                               fresh C a (Su p X)  
.

Hint Constructors fresh.

Notation "C |- a # t" := (fresh C a t) (at level 67).

(** Basic lemmas *)

Lemma fresh_At_elim : forall C a b, (C |- a # At b) -> a <> b.
Proof. intros. inversion H; trivial. Qed.

Hint Resolve fresh_At_elim.

Lemma fresh_Pr_elim : forall C a t u, 
(C |- a # <|t,u|>) -> ((C |- a # t) /\ (C |- a # u)).  
Proof. intros. inversion H; split~; trivial. Qed.

Hint Resolve fresh_Pr_elim.

Lemma fresh_Fc_elim : forall C a E n t,
(C |- a # Fc E n t) -> C |- a # t.
Proof. intros. inversion H; trivial. Qed. 

Hint Resolve fresh_Fc_elim.

Lemma fresh_Ab_elim : forall C a b t, 
(C |- a # Ab b t) -> (a = b \/ ((a <> b) /\ (C |- a # t))).
Proof. 
 intros. inversion H. 
 left~; trivial.
 right~; split~; trivial.
Qed.

Hint Resolve fresh_Ab_elim.

Lemma fresh_Su_elim : forall C p a X, 
(C |- a # Su p X) -> set_In (((!p $ a), X)) C.
Proof. intros. inversion H; trivial. Qed.

Hint Resolve fresh_Su_elim.


Lemma fresh_lemma_1 : forall C pi a t, 
(C |- a # (pi @ t)) -> (C |- ((!pi) $ a) # t).
Proof. 
 intros. induction t.
 apply fresh_Ut.
 apply fresh_At. rewrite perm_At in H. 
 inversion H. intro H'. apply H3.
 symmetry. apply perm_inv_side_atom.
 symmetry. trivial. case (((!pi) $ a) ==at a0). 
 intro H'. rewrite H'. apply fresh_Ab_1. 
 intro H'. apply fresh_Ab_2; trivial.
 apply IHt. rewrite perm_Ab in H.
 clear IHt. inversion H. symmetry in H3.
 apply perm_inv_side_atom in H3. symmetry in H3.
 contradiction. trivial.
 rewrite perm_Pr in H. inversion H. 
 apply fresh_Pr; [apply IHt1; trivial | apply IHt2; trivial].
 rewrite perm_Fc in H. inversion H.
 apply fresh_Fc. apply IHt; trivial.
 rewrite perm_Su in H. inversion H.
 apply fresh_Su. rewrite perm_comp_atom. 
 rewrite <- distr_rev. trivial.
Qed.

Hint Resolve fresh_lemma_1.

Lemma fresh_lemma_2 : forall C pi a t, 
(C |- (pi $ a) # t) -> (C |- a # (!pi @ t)).
Proof. 
 intros. induction t.
 rewrite perm_Ut. apply fresh_Ut.
 rewrite perm_At. apply fresh_At.
 inversion H. intro H'. apply H3.
 apply perm_inv_side_atom. trivial.
 rewrite perm_Ab. case (a ==at ((!pi) $ a0)). 
 intro H'. rewrite H'. apply fresh_Ab_1. 
 intro H'. apply fresh_Ab_2; trivial.
 apply IHt. clear IHt. inversion H. 
 apply perm_inv_side_atom in H3. 
 contradiction. trivial.
 rewrite perm_Pr. inversion H. 
 apply fresh_Pr; [apply IHt1; trivial | apply IHt2; trivial].
 rewrite perm_Fc. inversion H.
 apply fresh_Fc. apply IHt; trivial.
 rewrite perm_Su. inversion H.
 apply fresh_Su. rewrite perm_comp_atom in H3. 
 rewrite distr_rev. rewrite rev_involutive.
 trivial.
Qed.

Hint Resolve fresh_lemma_2.

Lemma fresh_lemma_3 : forall C pi a t, 
(C |- a # t) <-> (C |- (pi $ a) # (pi @ t)).  
Proof. 
 intros. split~; intro.
 gen_eq g : (!pi). intro H'.
 assert (Q : pi = !g). rewrite H'. rewrite rev_involutive. trivial.
 rewrite Q. apply fresh_lemma_2. rewrite <- Q. rewrite H'.
 rewrite perm_inv_atom. 
 trivial.
 apply fresh_lemma_1 in H.
 rewrite perm_inv_atom in H.
 trivial.
Qed.

Hint Resolve fresh_lemma_3.


(** About freshness, TPith and TPithdel *)
 
Lemma fresh_TPith_TPithdel : forall i a C t E n, 
 C |- a # t <-> (C |- a # TPith i t E n /\ C |- a # TPithdel i t E n).  
Proof.
 intros. gen i. induction t; intro.
 simpl; split~; auto. simpl; split~; intro H; try split~; auto; try apply H.
 simpl; split~; intro H; try split~; auto; try apply H.
 case (le_dec i (TPlength t1 E n)); intro H0.
 rewrite TPith_Pr_le; trivial. case (TPlength t1 E n === 1); intro H1.
 rewrite TPithdel_t1_Pr; trivial. split~; intro. apply fresh_Pr_elim in H.
 split~; try apply H. apply IHt1; apply H.
 apply fresh_Pr; try apply H. apply IHt1 with (i:=i); split~; try apply H.
 rewrite TPithdel_TPlength_1; trivial.
 rewrite TPithdel_Pr_le; trivial. split~; intro. apply fresh_Pr_elim in H.
 split~; [apply IHt1; apply H | apply fresh_Pr; [apply IHt1; apply H | apply H]].
 destruct H. apply fresh_Pr_elim in H2. destruct H2. apply fresh_Pr; trivial.
 apply IHt1 with (i:=i); split~; trivial.
 rewrite TPith_Pr_gt; try omega. case (TPlength t2 E n === 1); intro H1.
 rewrite TPithdel_t2_Pr; try omega. split~; intro. apply fresh_Pr_elim in H.
 split~; try apply H. apply IHt2; apply H. apply fresh_Pr; try apply H.
 apply IHt2 with (i:=i - TPlength t1 E n); split~; try apply H.
 rewrite TPithdel_TPlength_1; trivial.
 rewrite TPithdel_Pr_gt; try omega. split~; intro. apply fresh_Pr_elim in H.
 split~; [apply IHt2; apply H | apply fresh_Pr; [apply H |apply IHt2; apply H]].
 destruct H. apply fresh_Pr_elim in H2. destruct H2. apply fresh_Pr; trivial.
 apply IHt2 with (i:=i-TPlength t1 E n); split~; trivial. 
 split~; intro. apply fresh_Fc_elim in H.
 case ((n0,n1) ==np (E,n)); intro H0.
 inverts H0. autorewrite with tuples. case (TPlength t E n === 1); intro H0.
 rewrite TPithdel_TPlength_1; autorewrite with tuples; trivial. split~; auto.
 apply IHt; trivial. rewrite TPithdel_Fc_eq; trivial.
 split~; try apply fresh_Fc; apply IHt; trivial.
 rewrite TPith_Fc_diff; trivial. rewrite TPithdel_Fc_diff; trivial. split~; auto.
 apply fresh_Fc. destruct H. case ((n0,n1) ==np (E,n)); intro H1.
 inverts H1. autorewrite with tuples in H. apply IHt with (i:=i); split~; trivial.
 case (TPlength t E n === 1); intro H1.
 rewrite TPithdel_TPlength_1; autorewrite with tuples; trivial.
 rewrite TPithdel_Fc_eq in H0; trivial. apply fresh_Fc_elim in H0; trivial.
 rewrite TPith_Fc_diff in H; trivial. apply fresh_Fc_elim in H; trivial.
 simpl; split~; intro H; try split~; auto; try apply H.
Qed.


(* About rpl_super and freshness *)

Lemma fresh_rpl_super : forall C a S0 m t, C |- a # t <-> C |- a # rpl_super S0 m t.
Proof.
  intros. induction t; simpl; split~; intro;  auto.
  apply fresh_Ab_elim in H. destruct H. rewrite H. apply fresh_Ab_1.
  destruct H. apply fresh_Ab_2; trivial. apply IHt; trivial.
  apply fresh_Ab_elim in H. destruct H. rewrite H. apply fresh_Ab_1.
  destruct H. apply fresh_Ab_2; trivial. apply IHt; trivial.
  apply fresh_Pr_elim in H. destruct H. apply fresh_Pr; [apply IHt1 | apply IHt2]; trivial.
  apply fresh_Pr_elim in H. destruct H. apply fresh_Pr; [apply IHt1 | apply IHt2]; trivial.
  apply fresh_Fc_elim in H. case (set_In_dec eq_nat_dec n S0); intro H1;
  apply fresh_Fc; apply IHt; trivial.
  gen H. case (set_In_dec eq_nat_dec n S0); intros H H1;
  apply fresh_Fc_elim in H1; apply fresh_Fc; apply IHt; trivial.
Qed.