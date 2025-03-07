;; Uncertainty Principle-based Reward Distribution Contract

(define-map rewards
  { cycle-id: uint }
  {
    total-energy: uint,
    distribution-complete: bool
  }
)

(define-map miner-rewards
  { cycle-id: uint, miner-id: uint }
  { amount: uint }
)

(define-data-var current-cycle uint u0)

(define-public (start-new-cycle)
  (let
    ((cycle-id (var-get current-cycle)))
    (var-set current-cycle (+ cycle-id u1))
    (ok (map-set rewards
      { cycle-id: cycle-id }
      {
        total-energy: u0,
        distribution-complete: false
      }
    ))
  )
)

(define-public (contribute-energy (miner-id uint) (amount uint))
  (let
    ((cycle-id (var-get current-cycle))
     (current-total (get total-energy (default-to { total-energy: u0, distribution-complete: false } (map-get? rewards { cycle-id: cycle-id })))))
    (map-set rewards
      { cycle-id: cycle-id }
      {
        total-energy: (+ current-total amount),
        distribution-complete: false
      }
    )
    (ok (map-set miner-rewards
      { cycle-id: cycle-id, miner-id: miner-id }
      { amount: amount }
    ))
  )
)

(define-public (distribute-rewards (cycle-id uint))
  (match (map-get? rewards { cycle-id: cycle-id })
    reward-cycle
      (begin
        (asserts! (not (get distribution-complete reward-cycle)) (err u403))
        (ok (map-set rewards
          { cycle-id: cycle-id }
          (merge reward-cycle { distribution-complete: true })
        )))
    (err u404)
  )
)

(define-read-only (get-miner-reward (cycle-id uint) (miner-id uint))
  (default-to { amount: u0 } (map-get? miner-rewards { cycle-id: cycle-id, miner-id: miner-id }))
)

(define-read-only (get-cycle-info (cycle-id uint))
  (map-get? rewards { cycle-id: cycle-id })
)

